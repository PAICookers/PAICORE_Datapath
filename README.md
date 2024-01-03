# PAICORE_Datapath 

本数据通路实际上完成的64bit数据流的传输，并不限制平台，只要能够实现axis和axil协议的硬件平台即可。

目前支持的平台是7100和PCIe。


## 概述

rtl代码与硬件无关，通过tcl区分不同的硬件板卡对应的工程。

考虑流水线推理的数据通路

PCIe的axis读似乎并不快，还不如用axil将输出一个个读出来，对于分类任务来说，输出数目很少，没必要用stream（已经证伪，对于十来个数据，使用寄存器有一定加速效果，但也只在微妙级别，整个数据通路瓶颈并不在此）

反而是使用stream传输时数据，传100个和100000个数据，耗时差不太多。

## 数据通路设计细节

对于PCIe来说，数据发送时可能会产生多个TLAST信号，因此不能直接用TLAST，用axis_gen_last模块来生成正确的tlast信号，需要指定此次发送的数据量

而在接收时，需要明确知道接收多少个数据，因此使用axis_dataPadding模块将TLAST后的数据进行0的填充

在接收PAICORE数据时，用到了transport_up模块，需要对done和busy信号进行判断，后续要考虑双通道时该如何处理。

## TODO

有时通路会卡住，但PCIe CORE是正常的，芯片复位了，通路复位了，但就是无法工作？
设置一条旁路，将数据输出或接收？

## axil传输效率提升
注意：axil只支持32bit的数据位宽
### xilinx模板实现
** test_axil_regfile.run_test_read       PASS       1700.00           0.20       8587.49  **
** test_axil_regfile.run_test_read_001   PASS       1710.00           0.17      10269.43  **
** test_axil_regfile.run_test_read_002   PASS       2350.00           0.20      11977.40  **
** test_axil_regfile.run_test_read_003   PASS       2040.00           0.20      10217.33  **
** test_axil_regfile.run_test_read_004   PASS       2540.00           0.21      11882.83  **

### 改进读
** test_axil_regfile.run_test_read       PASS       1380.00           0.19       7339.58  **
** test_axil_regfile.run_test_read_001   PASS       1390.00           0.18       7762.26  **
** test_axil_regfile.run_test_read_002   PASS       2010.00           0.18      11179.71  **
** test_axil_regfile.run_test_read_003   PASS       1780.00           0.23       7908.94  **
** test_axil_regfile.run_test_read_004   PASS       2120.00           0.21      10055.13  **

### 改进读写
** test_axil_regfile.run_test_read       PASS         750.00           0.06      12254.89  **
** test_axil_regfile.run_test_read_001   PASS         760.00           0.04      19882.71  **
** test_axil_regfile.run_test_read_002   PASS        1070.00           0.05      23503.68  **
** test_axil_regfile.run_test_read_003   PASS        1350.00           0.12      10871.28  **
** test_axil_regfile.run_test_read_004   PASS        1430.00           0.11      12607.43  **

## 如果芯片确实没输出的时候，是否有进行处理？