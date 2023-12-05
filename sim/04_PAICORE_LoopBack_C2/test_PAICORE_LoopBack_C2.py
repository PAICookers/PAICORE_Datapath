#!/usr/bin/env python

import itertools
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

import numpy as np


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

        ports = 1

        self.source = [
            AxiStreamSource(
                AxiStreamBus.from_prefix(dut, f"s{k:02d}_axis"), dut.clk, dut.rst
            )
            for k in range(ports)
        ]
        self.sink = AxiStreamSink(
            AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst
        )

    # 上游停顿
    def set_idle_generator(self, generator=None):
        if generator:
            for source in self.source:
                source.set_pause_generator(generator())

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


@cocotb.test(timeout_time=200000, timeout_unit="ns")
async def run_test(dut, idle_inserter=None, backpressure_inserter=None):
    tb = TB(dut)
    byte_lanes = tb.source[0].byte_lanes  # 位宽字节数
    await tb.reset()

    tb.dut.i_rx_rcving.setimmediatevalue(1)

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    for k in range(10):
        length = random.randint(32, 64)
        # length = 5  # 数据个数
        if length % 2 == 1: ## 各通道平分数据，实际传输似可以用全0补齐
            length += 1
        tb.dut.send_len.setimmediatevalue(length)
        tb.dut.oFrameNumMax.setimmediatevalue(length)

        rand_data = random_int_list(0, 255, length * byte_lanes)
        test_data = bytearray(rand_data)
        test_frame = AxiStreamFrame(test_data)
        await tb.source[0].send(test_frame)


        rx_frame = await tb.sink.recv()
        inputFrames  = axisFrame2np(test_frame.tdata)
        outputFrames = axisFrame2np(rx_frame.tdata[: -1 * byte_lanes])
        inputFrames  = np.sort(inputFrames)
        outputFrames = np.sort(outputFrames)
        assert (inputFrames == outputFrames).all()

    assert tb.sink.empty()

    for i in range(100):
        await RisingEdge(dut.clk)


def cycle_pause():
    # return itertools.cycle([1, 1, 1, 0])
    return itertools.cycle(random_int_list(0, 1, 1024))


factory = TestFactory(run_test)
factory.add_option("idle_inserter", [None, cycle_pause])
factory.add_option("backpressure_inserter", [None, cycle_pause])
factory.generate_tests()
