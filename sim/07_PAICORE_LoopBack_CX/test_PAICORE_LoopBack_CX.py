#!/usr/bin/env python

import itertools
import random
random.seed(10)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

import numpy as np

from functools  import reduce

def toByteList(x, length=4):
    val = x.item().to_bytes(length=length, byteorder='little', signed=False)
    return val

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

        self.source = AxiStreamSource(
            AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst
        )

        self.sink = AxiStreamSink(
            AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst
        )

    # 上游停顿
    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

    # 下游反压
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


@cocotb.test(timeout_time=500000, timeout_unit="ns")
async def run_simple_test(dut, idle_inserter=None, backpressure_inserter=None):
    tb = TB(dut)
    byte_lanes = tb.source.byte_lanes  # 位宽字节数
    await tb.reset()

    tb.dut.i_rx_rcving.setimmediatevalue(1)

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    for k in range(10):
        # length = random.randint(32, 64)
        length = 64 # 数据个数
        tb.dut.single_channel.setimmediatevalue(0)
        tb.dut.single_channel_mask.setimmediatevalue(0b0001)
        tb.dut.send_len.setimmediatevalue(length)

        await RisingEdge(dut.clk) # oFrameNumMax change slowly, or it will be wrong
        tb.dut.oFrameNumMax.setimmediatevalue(length + 1)

        data_np = np.array([i+1 for i in range(length)])
        data_list = list(data_np)
        data_list = [toByteList(c, length=8) for c in data_list]
        data_bytes = reduce(lambda x,y:x+y,data_list)
        test_frame = AxiStreamFrame(data_bytes)

        await tb.source.send(test_frame)


        rx_frame = await tb.sink.recv()
        assert tb.sink.empty()
        inputFrames  = axisFrame2np(test_frame.tdata)
        outputFrames = axisFrame2np(rx_frame.tdata[: -1 * byte_lanes])
        inputFrames  = np.sort(inputFrames)
        outputFrames = np.sort(outputFrames)


        assert (inputFrames == outputFrames).all()
        

    for i in range(10):
        await RisingEdge(dut.clk)


# @cocotb.test(timeout_time=2000000, timeout_unit="ns")
async def run_full_test(dut, idle_inserter=None, backpressure_inserter=None):
    tb = TB(dut)
    byte_lanes = tb.source.byte_lanes  # 位宽字节数
    await tb.reset()

    tb.dut.i_rx_rcving.setimmediatevalue(1)

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    for k in range(50):
        length = random.randint(32, 64) * 10
        # length = 64 # 数据个数
        tb.dut.fork_enable.setimmediatevalue(1)
        tb.dut.send_len.setimmediatevalue(length)

        await RisingEdge(dut.clk) # oFrameNumMax change slowly, or it will be wrong
        tb.dut.oFrameNumMax.setimmediatevalue(length + 1)

        # data_np = np.array([i+1 for i in range(length)])
        # data_list = list(data_np)
        # data_list = [toByteList(c, length=8) for c in data_list]
        # data_bytes = reduce(lambda x,y:x+y,data_list)
        # test_frame = AxiStreamFrame(data_bytes)

        rand_data = random_int_list(0, 255, length * byte_lanes)
        test_data = bytearray(rand_data)
        test_frame = AxiStreamFrame(test_data)
        await tb.source.send(test_frame)


        rx_frame = await tb.sink.recv()
        assert tb.sink.empty()
        inputFrames  = axisFrame2np(test_frame.tdata)
        outputFrames = axisFrame2np(rx_frame.tdata[: -1 * byte_lanes])
        inputFrames  = np.sort(inputFrames)
        outputFrames = np.sort(outputFrames)


        assert (inputFrames == outputFrames).all()
        

    for i in range(100):
        await RisingEdge(dut.clk)

def cycle_pause():
    # return itertools.cycle([1, 1, 1, 0])
    # return itertools.cycle(random_int_list(0, 1, 1024))
    return itertools.cycle([1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0])
    


factory = TestFactory(run_simple_test)
factory.add_option("idle_inserter", [None, cycle_pause])
factory.add_option("backpressure_inserter", [None, cycle_pause])
factory.generate_tests()
