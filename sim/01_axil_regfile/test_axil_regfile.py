import itertools
import logging
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiLiteBus, AxiLiteMaster

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

class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axil"), dut.clk, dut.rst)

    def set_idle_generator(self, generator=None):
        if generator:
            self.axil_master.write_if.aw_channel.set_pause_generator(generator())
            self.axil_master.write_if.w_channel.set_pause_generator(generator())
            self.axil_master.read_if.ar_channel.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.axil_master.write_if.b_channel.set_pause_generator(generator())
            self.axil_master.read_if.r_channel.set_pause_generator(generator())

    async def cycle_reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

@cocotb.test(timeout_time=100000, timeout_unit="ns")
async def run_test_read(dut, data_in=None, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)
    byte_lanes = tb.axil_master.write_if.byte_lanes
    await tb.cycle_reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    addr = 0

    length = 1024
    rand_data = np.array(random_int_list(0,2**64-1,length),dtype=np.uint64)
    data_list = list(rand_data)
    data_list = [toByteList(c, length=byte_lanes) for c in data_list]
    test_data = reduce(lambda x,y:x+y,data_list)
    await tb.axil_master.write(addr, test_data)

    data = await tb.axil_master.read(addr, length * byte_lanes)

    assert data.data == test_data

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)


def cycle_pause():
    # return itertools.cycle([1, 1, 1, 0])
    return itertools.cycle(random_int_list(0,1,100))

factory = TestFactory(run_test_read)
factory.add_option("idle_inserter", [None, cycle_pause])
factory.add_option("backpressure_inserter", [None, cycle_pause])
factory.generate_tests()


# for test in [run_test_write, run_test_read]:

#     factory = TestFactory(test)
#     factory.add_option("idle_inserter", [None, cycle_pause])
#     factory.add_option("backpressure_inserter", [None, cycle_pause])
#     factory.generate_tests()

# factory = TestFactory(run_stress_test)
# factory.generate_tests()

