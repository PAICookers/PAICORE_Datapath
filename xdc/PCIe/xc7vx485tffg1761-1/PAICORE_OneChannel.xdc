set_property PACKAGE_PIN Y8 [get_ports {diff_clock_rtl_0_clk_p[0]}]
create_clock -name sys_clk -period 10 [get_ports {diff_clock_rtl_0_clk_p[0]}]

set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS18} [get_ports reset_rtl_0]
set_false_path -from [get_ports reset_rtl_0]
set_property PULLUP true [get_ports reset_rtl_0]

set_property -dict { PACKAGE_PIN AK20   IOSTANDARD LVCMOS18 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN AL20   IOSTANDARD LVCMOS18 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN AJ22   IOSTANDARD LVCMOS18 } [get_ports { LED[2] }];

# U3
# Ports of E2 (FPGA in / PAICORE out)
set_property -dict { PACKAGE_PIN AR38 IOSTANDARD LVCMOS18 } [get_ports E2_REQ]
set_property -dict { PACKAGE_PIN AP40 IOSTANDARD LVCMOS18 } [get_ports E2_ACK]
set_property -dict { PACKAGE_PIN AN40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[31]}]
set_property -dict { PACKAGE_PIN AM42 IOSTANDARD LVCMOS18 } [get_ports {din_E2[30]}]
set_property -dict { PACKAGE_PIN AM39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[29]}]
set_property -dict { PACKAGE_PIN AN38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[28]}]
set_property -dict { PACKAGE_PIN AT39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[27]}]
set_property -dict { PACKAGE_PIN AT40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[26]}]
set_property -dict { PACKAGE_PIN AR42 IOSTANDARD LVCMOS18 } [get_ports {din_E2[25]}]
set_property -dict { PACKAGE_PIN AR40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[24]}]
set_property -dict { PACKAGE_PIN AP38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[23]}]
set_property -dict { PACKAGE_PIN AM41 IOSTANDARD LVCMOS18 } [get_ports {din_E2[22]}]
set_property -dict { PACKAGE_PIN AR37 IOSTANDARD LVCMOS18 } [get_ports {din_E2[21]}]
set_property -dict { PACKAGE_PIN AU42 IOSTANDARD LVCMOS18 } [get_ports {din_E2[20]}]
set_property -dict { PACKAGE_PIN AR39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[19]}]
set_property -dict { PACKAGE_PIN AT41 IOSTANDARD LVCMOS18 } [get_ports {din_E2[18]}]
set_property -dict { PACKAGE_PIN AT42 IOSTANDARD LVCMOS18 } [get_ports {din_E2[17]}]
set_property -dict { PACKAGE_PIN AP42 IOSTANDARD LVCMOS18 } [get_ports {din_E2[16]}]
set_property -dict { PACKAGE_PIN AN41 IOSTANDARD LVCMOS18 } [get_ports {din_E2[15]}]
set_property -dict { PACKAGE_PIN AN39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[14]}]
set_property -dict { PACKAGE_PIN AY40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[13]}]
set_property -dict { PACKAGE_PIN AV38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[12]}]
set_property -dict { PACKAGE_PIN AV40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[11]}]
set_property -dict { PACKAGE_PIN AV39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[10]}]
set_property -dict { PACKAGE_PIN AT37 IOSTANDARD LVCMOS18 } [get_ports {din_E2[9]}]
set_property -dict { PACKAGE_PIN AU39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[8]}]
set_property -dict { PACKAGE_PIN AP41 IOSTANDARD LVCMOS18 } [get_ports {din_E2[7]}]
set_property -dict { PACKAGE_PIN AU38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[6]}]
set_property -dict { PACKAGE_PIN AW40 IOSTANDARD LVCMOS18 } [get_ports {din_E2[5]}]
set_property -dict { PACKAGE_PIN AW38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[4]}]
set_property -dict { PACKAGE_PIN AY39 IOSTANDARD LVCMOS18 } [get_ports {din_E2[3]}]
set_property -dict { PACKAGE_PIN AY38 IOSTANDARD LVCMOS18 } [get_ports {din_E2[2]}]
set_property -dict { PACKAGE_PIN AW37 IOSTANDARD LVCMOS18 } [get_ports {din_E2[1]}]
set_property -dict { PACKAGE_PIN AY37 IOSTANDARD LVCMOS18 } [get_ports {din_E2[0]}]

# Ports of E6 (FPGA out / PAICORE in)
set_property -dict { PACKAGE_PIN AU22 IOSTANDARD LVCMOS18 } [get_ports E6_REQ]
set_property -dict { PACKAGE_PIN AW21 IOSTANDARD LVCMOS18 } [get_ports E6_ACK]
set_property -dict { PACKAGE_PIN AV23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[31]}]
set_property -dict { PACKAGE_PIN AW23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[30]}]
set_property -dict { PACKAGE_PIN AU24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[29]}]
set_property -dict { PACKAGE_PIN AY25 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[28]}]
set_property -dict { PACKAGE_PIN AT22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[27]}]
set_property -dict { PACKAGE_PIN AU21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[26]}]
set_property -dict { PACKAGE_PIN AR22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[25]}]
set_property -dict { PACKAGE_PIN AV21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[24]}]
set_property -dict { PACKAGE_PIN AU23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[23]}]
set_property -dict { PACKAGE_PIN AY23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[22]}]
set_property -dict { PACKAGE_PIN AV24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[21]}]
set_property -dict { PACKAGE_PIN AR24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[20]}]
set_property -dict { PACKAGE_PIN AP22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[19]}]
set_property -dict { PACKAGE_PIN AN23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[18]}]
set_property -dict { PACKAGE_PIN AN21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[17]}]
set_property -dict { PACKAGE_PIN AR23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[16]}]
set_property -dict { PACKAGE_PIN AW22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[15]}]
set_property -dict { PACKAGE_PIN AT24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[14]}]
set_property -dict { PACKAGE_PIN AP23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[13]}]
set_property -dict { PACKAGE_PIN AP21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[12]}]
set_property -dict { PACKAGE_PIN AM21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[11]}]
set_property -dict { PACKAGE_PIN AL22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[10]}]
set_property -dict { PACKAGE_PIN AM24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[9]}]
set_property -dict { PACKAGE_PIN AN24 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[8]}]
set_property -dict { PACKAGE_PIN AY22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[7]}]
set_property -dict { PACKAGE_PIN AM22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[6]}]
set_property -dict { PACKAGE_PIN AL21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[5]}]
set_property -dict { PACKAGE_PIN AM23 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[4]}]
set_property -dict { PACKAGE_PIN AK22 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[3]}]
set_property -dict { PACKAGE_PIN AJ20 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[2]}]
set_property -dict { PACKAGE_PIN AJ21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[1]}]
set_property -dict { PACKAGE_PIN AT21 IOSTANDARD LVCMOS18 } [get_ports {dout_E6[0]}]

# E control signals
set_property -dict { PACKAGE_PIN AV41 IOSTANDARD LVCMOS18 } [get_ports E_DONE ];
set_property -dict { PACKAGE_PIN AW41 IOSTANDARD LVCMOS18 } [get_ports E_BUSY ];
set_property -dict { PACKAGE_PIN AU41 IOSTANDARD LVCMOS18 } [get_ports { E_CTRL[0] } ]; # E_CLC
set_property -dict { PACKAGE_PIN AW42 IOSTANDARD LVCMOS18 } [get_ports { E_CTRL[1] } ]; # E_SYNC
set_property -dict { PACKAGE_PIN AY42 IOSTANDARD LVCMOS18 } [get_ports { E_CTRL[2] } ]; # E_INT

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]