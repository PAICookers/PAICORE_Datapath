
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# PAICORE_recv, PAICORE_regfile, PAICORE_send, axil_regfile_axis_wr_wrapper, timeMeasure

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7vx485tffg1761-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xdma:4.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
PAICORE_recv\
PAICORE_regfile\
PAICORE_send\
axil_regfile_axis_wr_wrapper\
timeMeasure\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: pl_datapath
proc create_hier_cell_pl_datapath { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pl_datapath() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_BYPASS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_LITE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_RF

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axil


  # Create pins
  create_bd_pin -dir O -from 2 -to 0 E_CTRL
  create_bd_pin -dir I acknowledge_0
  create_bd_pin -dir O acknowledge_1
  create_bd_pin -dir O -type clk axi_aclk
  create_bd_pin -dir O -type rst axi_aresetn
  create_bd_pin -dir I -from 31 -to 0 din_0
  create_bd_pin -dir O -from 31 -to 0 dout_0
  create_bd_pin -dir I i_recv_busy_0
  create_bd_pin -dir I i_recv_done_0
  create_bd_pin -dir O request_0
  create_bd_pin -dir I request_1
  create_bd_pin -dir I -type rst reset_rtl_0
  create_bd_pin -dir I -type clk sys_clk

  # Create instance: PAICORE_recv_0, and set properties
  set block_name PAICORE_recv
  set block_cell_name PAICORE_recv_0
  if { [catch {set PAICORE_recv_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PAICORE_recv_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: PAICORE_regfile_0, and set properties
  set block_name PAICORE_regfile
  set block_cell_name PAICORE_regfile_0
  if { [catch {set PAICORE_regfile_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PAICORE_regfile_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: PAICORE_send_0, and set properties
  set block_name PAICORE_send
  set block_cell_name PAICORE_send_0
  if { [catch {set PAICORE_send_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PAICORE_send_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axil_regfile_axis_wr_0, and set properties
  set block_name axil_regfile_axis_wr_wrapper
  set block_cell_name axil_regfile_axis_wr_0
  if { [catch {set axil_regfile_axis_wr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axil_regfile_axis_wr_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: timeMeasure_0, and set properties
  set block_name timeMeasure
  set block_cell_name timeMeasure_0
  if { [catch {set timeMeasure_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $timeMeasure_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.PF0_DEVICE_ID_mqdma {9014} \
   CONFIG.PF2_DEVICE_ID_mqdma {9014} \
   CONFIG.PF3_DEVICE_ID_mqdma {9014} \
   CONFIG.axi_data_width {64_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_scale {Kilobytes} \
   CONFIG.axilite_master_size {256} \
   CONFIG.axist_bypass_en {true} \
   CONFIG.axist_bypass_scale {Kilobytes} \
   CONFIG.axist_bypass_size {256} \
   CONFIG.axisten_freq {125} \
   CONFIG.cfg_mgmt_if {false} \
   CONFIG.coreclk_freq {250} \
   CONFIG.dedicate_perst {false} \
   CONFIG.enable_lane_reversal {true} \
   CONFIG.pcie_blk_locn {X1Y0} \
   CONFIG.pciebar2axibar_axil_master {0x40000000} \
   CONFIG.pciebar2axibar_axist_bypass {0x50000000} \
   CONFIG.pf0_device_id {7014} \
   CONFIG.pf0_interrupt_pin {NONE} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
   CONFIG.pl_link_cap_max_link_speed {2.5_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X4} \
   CONFIG.plltype {CPLL} \
   CONFIG.select_quad {GTH_Quad_128} \
   CONFIG.xdma_axi_intf_mm {AXI_Stream} \
   CONFIG.xdma_axilite_slave {false} \
   CONFIG.xdma_num_usr_irq {5} \
   CONFIG.xdma_rnum_chnl {1} \
   CONFIG.xdma_wnum_chnl {1} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI_RF] [get_bd_intf_pins PAICORE_regfile_0/S_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins s_axil] [get_bd_intf_pins axil_regfile_axis_wr_0/s_axil]
  connect_bd_intf_net -intf_net PAICORE_recv_0_m_axis [get_bd_intf_pins PAICORE_recv_0/m_axis] [get_bd_intf_pins axil_regfile_axis_wr_0/s_axis]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_0 [get_bd_intf_pins PAICORE_send_0/s_axis] [get_bd_intf_pins xdma_0/M_AXIS_H2C_0]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS [get_bd_intf_pins M_AXI_BYPASS] [get_bd_intf_pins xdma_0/M_AXI_BYPASS]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins M_AXI_LITE] [get_bd_intf_pins xdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_pins pcie_mgt_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net PAICORE_recv_0_acknowledge [get_bd_pins acknowledge_1] [get_bd_pins PAICORE_recv_0/acknowledge]
  connect_bd_net -net PAICORE_recv_0_o_rx_done [get_bd_pins PAICORE_recv_0/o_rx_done] [get_bd_pins PAICORE_regfile_0/i_rx_done] [get_bd_pins timeMeasure_0/recv_done]
  connect_bd_net -net PAICORE_recv_0_read_data [get_bd_pins PAICORE_recv_0/read_data] [get_bd_pins PAICORE_regfile_0/read_data]
  connect_bd_net -net PAICORE_recv_0_read_hsked [get_bd_pins PAICORE_recv_0/read_hsked] [get_bd_pins PAICORE_regfile_0/fifo2cpu_plus]
  connect_bd_net -net PAICORE_recv_0_snn_out_hsked [get_bd_pins PAICORE_recv_0/snn_out_hsked] [get_bd_pins PAICORE_regfile_0/snn2fifo_plus]
  connect_bd_net -net PAICORE_regfile_0_DataPath_Reset_n [get_bd_pins PAICORE_recv_0/m_axis_aresetn] [get_bd_pins PAICORE_regfile_0/DataPath_Reset_n] [get_bd_pins PAICORE_send_0/s_axis_aresetn] [get_bd_pins axil_regfile_axis_wr_0/s_axis_aresetn] [get_bd_pins timeMeasure_0/rst_n]
  connect_bd_net -net PAICORE_regfile_0_PAICORE_CTRL [get_bd_pins E_CTRL] [get_bd_pins PAICORE_regfile_0/PAICORE_CTRL]
  connect_bd_net -net PAICORE_regfile_0_oFrameNumMax [get_bd_pins PAICORE_recv_0/oFrameNumMax] [get_bd_pins PAICORE_regfile_0/oFrameNumMax]
  connect_bd_net -net PAICORE_regfile_0_o_rx_rcving [get_bd_pins PAICORE_recv_0/i_rx_rcving] [get_bd_pins PAICORE_regfile_0/o_rx_rcving]
  connect_bd_net -net PAICORE_regfile_0_send_len [get_bd_pins PAICORE_regfile_0/send_len] [get_bd_pins PAICORE_send_0/send_len]
  connect_bd_net -net PAICORE_send_0_dout [get_bd_pins dout_0] [get_bd_pins PAICORE_send_0/dout]
  connect_bd_net -net PAICORE_send_0_o_tx_done [get_bd_pins PAICORE_regfile_0/i_tx_done] [get_bd_pins PAICORE_send_0/o_tx_done] [get_bd_pins timeMeasure_0/send_done]
  connect_bd_net -net PAICORE_send_0_request [get_bd_pins request_0] [get_bd_pins PAICORE_send_0/request]
  connect_bd_net -net PAICORE_send_0_snn_in_hsked [get_bd_pins PAICORE_regfile_0/fifo2snn_plus] [get_bd_pins PAICORE_send_0/snn_in_hsked]
  connect_bd_net -net PAICORE_send_0_write_data [get_bd_pins PAICORE_regfile_0/write_data] [get_bd_pins PAICORE_send_0/write_data]
  connect_bd_net -net PAICORE_send_0_write_hsked [get_bd_pins PAICORE_regfile_0/cpu2fifo_plus] [get_bd_pins PAICORE_send_0/write_hsked]
  connect_bd_net -net acknowledge_0_1 [get_bd_pins acknowledge_0] [get_bd_pins PAICORE_send_0/acknowledge]
  connect_bd_net -net axil_regfile_axis_wr_0_axis_write_num [get_bd_pins PAICORE_regfile_0/data_cnt] [get_bd_pins axil_regfile_axis_wr_0/axis_write_num]
  connect_bd_net -net din_0_1 [get_bd_pins din_0] [get_bd_pins PAICORE_recv_0/din]
  connect_bd_net -net i_recv_busy_0_1 [get_bd_pins i_recv_busy_0] [get_bd_pins PAICORE_recv_0/i_recv_busy]
  connect_bd_net -net i_recv_done_0_1 [get_bd_pins i_recv_done_0] [get_bd_pins PAICORE_recv_0/i_recv_done]
  connect_bd_net -net request_1_1 [get_bd_pins request_1] [get_bd_pins PAICORE_recv_0/request]
  connect_bd_net -net reset_rtl_0_1 [get_bd_pins reset_rtl_0] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net timeMeasure_0_us_tick_num [get_bd_pins PAICORE_regfile_0/tlast_cnt] [get_bd_pins timeMeasure_0/us_tick_num]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins sys_clk] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_aclk] [get_bd_pins PAICORE_recv_0/m_axis_aclk] [get_bd_pins PAICORE_regfile_0/S_AXI_ACLK] [get_bd_pins PAICORE_send_0/s_axis_aclk] [get_bd_pins axil_regfile_axis_wr_0/s_axil_clk] [get_bd_pins axil_regfile_axis_wr_0/s_axis_clk] [get_bd_pins timeMeasure_0/clk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins axi_aresetn] [get_bd_pins PAICORE_regfile_0/S_AXI_ARESETN] [get_bd_pins axil_regfile_axis_wr_0/s_axil_aresetn] [get_bd_pins xdma_0/axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set diff_clock_rtl_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clock_rtl_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $diff_clock_rtl_0

  set pcie_mgt_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt_0 ]


  # Create ports
  set E2_ACK [ create_bd_port -dir O E2_ACK ]
  set E2_REQ [ create_bd_port -dir I E2_REQ ]
  set E6_ACK [ create_bd_port -dir I E6_ACK ]
  set E6_REQ [ create_bd_port -dir O E6_REQ ]
  set E_BUSY [ create_bd_port -dir I E_BUSY ]
  set E_CTRL [ create_bd_port -dir O -from 2 -to 0 E_CTRL ]
  set E_DONE [ create_bd_port -dir I E_DONE ]
  set LED [ create_bd_port -dir O -from 2 -to 0 LED ]
  set din_E2 [ create_bd_port -dir I -from 31 -to 0 din_E2 ]
  set dout_E6 [ create_bd_port -dir O -from 31 -to 0 dout_E6 ]
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_1

  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_2

  # Create instance: pl_datapath
  create_hier_cell_pl_datapath [current_bd_instance .] pl_datapath

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {3} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: xdma_0_axi_periph, and set properties
  set xdma_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 xdma_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $xdma_0_axi_periph

  # Create instance: xdma_0_axi_periph_1, and set properties
  set xdma_0_axi_periph_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 xdma_0_axi_periph_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $xdma_0_axi_periph_1

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports diff_clock_rtl_0] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_BYPASS [get_bd_intf_pins pl_datapath/M_AXI_BYPASS] [get_bd_intf_pins xdma_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins pl_datapath/M_AXI_LITE] [get_bd_intf_pins xdma_0_axi_periph_1/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_1_M00_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins xdma_0_axi_periph_1/M00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_1_M01_AXI [get_bd_intf_pins axi_gpio_2/S_AXI] [get_bd_intf_pins xdma_0_axi_periph_1/M01_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M00_AXI [get_bd_intf_pins pl_datapath/S_AXI_RF] [get_bd_intf_pins xdma_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins xdma_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M02_AXI [get_bd_intf_pins pl_datapath/s_axil] [get_bd_intf_pins xdma_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_mgt_0] [get_bd_intf_pins pl_datapath/pcie_mgt_0]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_gpio_2/s_axi_aresetn] [get_bd_pins pl_datapath/axi_aresetn] [get_bd_pins xdma_0_axi_periph/ARESETN] [get_bd_pins xdma_0_axi_periph/M00_ARESETN] [get_bd_pins xdma_0_axi_periph/M01_ARESETN] [get_bd_pins xdma_0_axi_periph/M02_ARESETN] [get_bd_pins xdma_0_axi_periph/S00_ARESETN] [get_bd_pins xdma_0_axi_periph_1/ARESETN] [get_bd_pins xdma_0_axi_periph_1/M00_ARESETN] [get_bd_pins xdma_0_axi_periph_1/M01_ARESETN] [get_bd_pins xdma_0_axi_periph_1/S00_ARESETN]
  connect_bd_net -net acknowledge_0_1 [get_bd_ports E6_ACK] [get_bd_pins pl_datapath/acknowledge_0]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_gpio_2_gpio_io_o [get_bd_pins axi_gpio_2/gpio_io_o] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net din_0_1 [get_bd_ports din_E2] [get_bd_pins pl_datapath/din_0]
  connect_bd_net -net i_recv_busy_0_1 [get_bd_ports E_BUSY] [get_bd_pins pl_datapath/i_recv_busy_0]
  connect_bd_net -net i_recv_done_0_1 [get_bd_ports E_DONE] [get_bd_pins pl_datapath/i_recv_done_0]
  connect_bd_net -net pl_datapath_PAICORE_CTRL_0 [get_bd_ports E_CTRL] [get_bd_pins pl_datapath/E_CTRL]
  connect_bd_net -net pl_datapath_acknowledge_1 [get_bd_ports E2_ACK] [get_bd_pins pl_datapath/acknowledge_1]
  connect_bd_net -net pl_datapath_dout_0 [get_bd_ports dout_E6] [get_bd_pins pl_datapath/dout_0]
  connect_bd_net -net pl_datapath_request_0 [get_bd_ports E6_REQ] [get_bd_pins pl_datapath/request_0]
  connect_bd_net -net request_0_1 [get_bd_ports E2_REQ] [get_bd_pins pl_datapath/request_1]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports reset_rtl_0] [get_bd_pins pl_datapath/reset_rtl_0]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins pl_datapath/sys_clk] [get_bd_pins util_ds_buf/IBUF_OUT]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_ports LED] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_gpio_2/s_axi_aclk] [get_bd_pins pl_datapath/axi_aclk] [get_bd_pins xdma_0_axi_periph/ACLK] [get_bd_pins xdma_0_axi_periph/M00_ACLK] [get_bd_pins xdma_0_axi_periph/M01_ACLK] [get_bd_pins xdma_0_axi_periph/M02_ACLK] [get_bd_pins xdma_0_axi_periph/S00_ACLK] [get_bd_pins xdma_0_axi_periph_1/ACLK] [get_bd_pins xdma_0_axi_periph_1/M00_ACLK] [get_bd_pins xdma_0_axi_periph_1/M01_ACLK] [get_bd_pins xdma_0_axi_periph_1/S00_ACLK]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins util_vector_logic_0/Op1] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  assign_bd_address -offset 0x50000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_datapath/xdma_0/M_AXI_BYPASS] [get_bd_addr_segs pl_datapath/PAICORE_regfile_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x50010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_datapath/xdma_0/M_AXI_BYPASS] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_datapath/xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_datapath/xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x50020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_datapath/xdma_0/M_AXI_BYPASS] [get_bd_addr_segs pl_datapath/axil_regfile_axis_wr_0/s_axil/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


