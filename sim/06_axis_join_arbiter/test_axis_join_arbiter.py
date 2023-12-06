#!/usr/bin/env python

import itertools
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

import numpy as np
import os

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

        self.ports = int(os.getenv("PORTS"))

        self.source = [
            AxiStreamSource(
                AxiStreamBus.from_prefix(dut, f"s{k:02d}_axis"), dut.clk, dut.rst
            )
            for k in range(self.ports)
        ]
        self.sink = AxiStreamSink(
            AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst
        )

    def set_idle_generator(self, generator=None):
        if generator:
            for source in self.source:
                source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

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
    byte_lanes = tb.source[0].byte_lanes  # 位宽字节数
    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    for k in range(10):
        length = random.randint(32, 64) * 10
        # length = 10  # 数据个数
    
        inputFrames = np.array([],dtype=np.uint64)
        for i in range(tb.ports):
            rand_data = random_int_list(0, 255, length * byte_lanes)
            test_data = bytearray(rand_data)
            test_frame = AxiStreamFrame(test_data)
            await tb.source[i].send(test_frame)
            inputFrame = axisFrame2np(test_frame.tdata)
            inputFrames = np.append(inputFrames,inputFrame)

        rx_frame = await tb.sink.recv()
        outputFrames = axisFrame2np(rx_frame.tdata)

        inputFrames  = np.sort(inputFrames)
        outputFrames = np.sort(outputFrames)
        assert (inputFrames == outputFrames).all()
    
    for i in range(100):
        await RisingEdge(dut.clk)


def cycle_pause():
    # return itertools.cycle([1, 1, 1, 0])
    return itertools.cycle(random_int_list(0, 1, 1024))

factory = TestFactory(run_test)
factory.add_option("idle_inserter", [None, cycle_pause])
factory.add_option("backpressure_inserter", [None, cycle_pause])
factory.generate_tests()
