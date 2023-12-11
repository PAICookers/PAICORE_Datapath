#!/usr/bin/env python

import itertools
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

import numpy as np
import logging
import os


def remove_duplicate_lines(input_file, output_file):
    with open(input_file, 'r') as infile:
        lines = infile.readlines()

    # 删除连续重复的行
    unique_lines = [lines[0]]
    for line in lines[1:]:
        if line != unique_lines[-1]:
            unique_lines.append(line)

    with open(output_file, 'w') as outfile:
        outfile.writelines(unique_lines)


def random_int_list(start, stop, length):
    start, stop = (int(start), int(stop)) if start <= stop else (int(stop), int(start))
    length = int(abs(length)) if length else 0
    random_list = []
    for i in range(length):
        random_list.append(random.randint(start, stop))
    return random_list


def axisFrame2np(frame):
    frame_btye = frame
    frame_btye_num = int(len(frame_btye) / 8)
    np_data = np.frombuffer(frame_btye, count=frame_btye_num, dtype=np.uint64)

    return np_data


class TB(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        formatter = logging.Formatter('%(funcName)s [line:%(lineno)d] %(levelname)s %(message)s')

        fh = logging.FileHandler("test.log", encoding='utf8')
        fh.setFormatter(formatter)
        self.log.addHandler(fh)

        self.ports = int(os.getenv("PORTS"))

        self.source = AxiStreamSource(
            AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst
        )
        self.sink = [
            AxiStreamSink(
                AxiStreamBus.from_prefix(dut, f"m{k:02d}_axis"), dut.clk, dut.rst
            )
            for k in range(self.ports)
        ]

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            for sink in self.sink:
                sink.set_pause_generator(generator())

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)


@cocotb.test(timeout_time=2000000, timeout_unit="ns")
async def run_test(dut, idle_inserter=None, backpressure_inserter=None):
    tb = TB(dut)
    byte_lanes = tb.source.byte_lanes  # 位宽字节数
    await tb.reset()

    # if not fork_enable, then only first channel can send data
    tb.dut.fork_enable.setimmediatevalue(1)
    tb.dut.single_mask.setimmediatevalue(0b001)
    
    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    test_str = ""
    if idle_inserter is not None:
        test_str += "_idle"
    if backpressure_inserter is not None:
        test_str += "_backpressure"
    tb.log.info("run" + test_str + "_test")    
    for k in range(10):
        length = random.randint(32, 64) * 10 * tb.ports
        # length = 10  # 数据个数

        rand_data = random_int_list(0, 255, length * byte_lanes)
        test_data = bytearray(rand_data)
        test_frame = AxiStreamFrame(test_data)
        await tb.source.send(test_frame)

        inputFrames  = np.array([2**64-1]*tb.ports,dtype=np.uint64)
        inputFrames  = np.append(inputFrames,axisFrame2np(test_frame.tdata))
        
        outputFrames = np.array([],dtype=np.uint64)
        for i in range(tb.ports):
            rx_frame = await tb.sink[i].recv()
            outputFrame = axisFrame2np(rx_frame.tdata)
            outputFrames = np.append(outputFrames,outputFrame)
            tb.log.info("channel {:d} : {:d}".format(i,outputFrame.size - 1))
            if(tb.dut.fork_enable.value == 0 and i != 0):
                assert (outputFrame.size - 1 == 0)
        tb.log.info("\n")
        inputFrames  = np.sort(inputFrames)
        outputFrames = np.sort(outputFrames)
        assert (inputFrames == outputFrames).all()

    for i in range(100):
        await RisingEdge(dut.clk)

    remove_duplicate_lines('test.log', 'test.log')


def cycle_pause():
    # return itertools.cycle([1, 1, 1, 0])
    return itertools.cycle(random_int_list(0, 1, 1024))

if os.path.exists("test.log"):
    os.remove("test.log")
factory = TestFactory(run_test)
factory.add_option("idle_inserter", [None, cycle_pause])
factory.add_option("backpressure_inserter", [None, cycle_pause])
factory.generate_tests()
