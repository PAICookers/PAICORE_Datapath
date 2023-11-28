`resetall
`timescale 1ns / 1ps
`default_nettype none

module axil_regfile_axis_wr_wrapper #
(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter REG_NUM    = 1024
)
(
    input  wire                     s_axis_clk,
    input  wire                     s_axis_aresetn,

    input  wire                     s_axil_clk,
    input  wire                     s_axil_aresetn,

    output wire                     s_axis_tready,
    input  wire[DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                     s_axis_tlast,
    input  wire                     s_axis_tvalid,

    output reg [31:0]               axis_write_num,

    input  wire [ADDR_WIDTH-1:0]    s_axil_awaddr,
    input  wire [2:0]               s_axil_awprot,
    input  wire                     s_axil_awvalid,
    output wire                     s_axil_awready,

    input  wire [DATA_WIDTH-1:0]    s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axil_wstrb,
    input  wire                     s_axil_wvalid,
    output wire                     s_axil_wready,

    output wire [1:0]               s_axil_bresp,
    output wire                     s_axil_bvalid,
    input  wire                     s_axil_bready,

    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr,
    input  wire [2:0]               s_axil_arprot,
    input  wire                     s_axil_arvalid,
    output wire                     s_axil_arready,

    output wire [DATA_WIDTH-1:0]    s_axil_rdata,
    output wire [1:0]               s_axil_rresp,
    output wire                     s_axil_rvalid,
    input  wire                     s_axil_rready

);

    axil_regfile_axis_wr #
    (
        .DATA_WIDTH     (DATA_WIDTH     ),
        .ADDR_WIDTH     (ADDR_WIDTH     ),
        .STRB_WIDTH     (STRB_WIDTH     ),
        .REG_NUM        (REG_NUM        )
    ) u_axil_regfile_axis_wr (
        .axil_clk       (s_axil_clk     ),
        .axil_rst       (!s_axil_aresetn),
        .axis_clk       (s_axis_clk     ),
        .axis_rst       (!s_axis_aresetn),
        .s_axis_tready  (s_axis_tready  ),
        .s_axis_tdata   (s_axis_tdata   ),
        .s_axis_tlast   (s_axis_tlast   ),
        .s_axis_tvalid  (s_axis_tvalid  ),
        .axis_write_num (axis_write_num ),
        .s_axil_awaddr  (s_axil_awaddr  ),
        .s_axil_awprot  (s_axil_awprot  ),
        .s_axil_awvalid (s_axil_awvalid ),
        .s_axil_awready (s_axil_awready ),
        .s_axil_wdata   (s_axil_wdata   ),
        .s_axil_wstrb   (s_axil_wstrb   ),
        .s_axil_wvalid  (s_axil_wvalid  ),
        .s_axil_wready  (s_axil_wready  ),
        .s_axil_bresp   (s_axil_bresp   ),
        .s_axil_bvalid  (s_axil_bvalid  ),
        .s_axil_bready  (s_axil_bready  ),
        .s_axil_araddr  (s_axil_araddr  ),
        .s_axil_arprot  (s_axil_arprot  ),
        .s_axil_arvalid (s_axil_arvalid ),
        .s_axil_arready (s_axil_arready ),
        .s_axil_rdata   (s_axil_rdata   ),
        .s_axil_rresp   (s_axil_rresp   ),
        .s_axil_rvalid  (s_axil_rvalid  ),
        .s_axil_rready  (s_axil_rready  )
    );

    
endmodule


`resetall