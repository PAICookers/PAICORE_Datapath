

// Language: Verilog 2001

/*
 * AXI4-Stream 3 port join arbiter mux (wrapper)
 */
module axis_join_arbiter_wrap_3 #
(
    parameter DATA_WIDTH = 64
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [3-1:0]         ien,

    /*
     * AXI Stream inputs
     */
    input  wire                   s00_axis_tvalid,
    input  wire [DATA_WIDTH-1:0]  s00_axis_tdata ,
    input  wire                   s00_axis_tlast ,
    output wire                   s00_axis_tready,

    input  wire                   s01_axis_tvalid,
    input  wire [DATA_WIDTH-1:0]  s01_axis_tdata ,
    input  wire                   s01_axis_tlast ,
    output wire                   s01_axis_tready,

    input  wire                   s02_axis_tvalid,
    input  wire [DATA_WIDTH-1:0]  s02_axis_tdata ,
    input  wire                   s02_axis_tlast ,
    output wire                   s02_axis_tready,

    /*
     * AXI Stream output
     */
    output wire                   m_axis_tvalid,
    output wire [DATA_WIDTH-1:0]  m_axis_tdata ,
    output wire                   m_axis_tlast ,
    input  wire                   m_axis_tready
);

axis_join_arbiter #(
    .S_COUNT(3),
    .DATA_WIDTH(DATA_WIDTH)
)
axis_join_arbiter_inst (
    .clk(clk),
    .rst(rst),
    .ien(ien),

    // AXI inputs
    .s_axis_tvalid({ s02_axis_tvalid, s01_axis_tvalid, s00_axis_tvalid }),
    .s_axis_tdata({ s02_axis_tdata, s01_axis_tdata, s00_axis_tdata }),
    .s_axis_tlast({ s02_axis_tlast, s01_axis_tlast, s00_axis_tlast }),
    .s_axis_tready({ s02_axis_tready, s01_axis_tready, s00_axis_tready }),
    // AXI output
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tready(m_axis_tready)
);

endmodule

