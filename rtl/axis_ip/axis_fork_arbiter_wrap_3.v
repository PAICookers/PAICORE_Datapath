

// Language: Verilog 2001

/*
 * AXI4-Stream 3 port fork arbiter mux (wrapper)
 */
module axis_fork_arbiter_wrap_3 #
(
    parameter DATA_WIDTH = 64
)
(
    input  wire                     clk,
    input  wire                     rst,
                 
    input                           fork_enable,

    /*
     * AXI Stream input
     */
    output wire                     s_axis_tready,
    input  wire [DATA_WIDTH-1:0]    s_axis_tdata,
    input  wire                     s_axis_tlast,
    input  wire                     s_axis_tvalid,

    /*
     * AXI Stream outputs
     */
    input  wire                     m00_axis_tready,
    output wire [DATA_WIDTH-1:0]    m00_axis_tdata,
    output wire                     m00_axis_tlast,
    output wire                     m00_axis_tvalid,

    input  wire                     m01_axis_tready,
    output wire [DATA_WIDTH-1:0]    m01_axis_tdata,
    output wire                     m01_axis_tlast,
    output wire                     m01_axis_tvalid,

    input  wire                     m02_axis_tready,
    output wire [DATA_WIDTH-1:0]    m02_axis_tdata,
    output wire                     m02_axis_tlast,
    output wire                     m02_axis_tvalid
);

axis_fork_arbiter #(
    .M_COUNT(3),
    .DATA_WIDTH(DATA_WIDTH)
)
axis_fork_arbiter_inst (
    .clk(clk),
    .rst(rst),
    .fork_enable(fork_enable),

    // AXI input
    .s_axis_tready(s_axis_tready),                 
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tvalid(s_axis_tvalid),

    // AXI outputs
    .m_axis_tready({ m02_axis_tready, m01_axis_tready, m00_axis_tready }),
    .m_axis_tdata({ m02_axis_tdata, m01_axis_tdata, m00_axis_tdata }),
    .m_axis_tlast({ m02_axis_tlast, m01_axis_tlast, m00_axis_tlast }),
    .m_axis_tvalid({ m02_axis_tvalid, m01_axis_tvalid, m00_axis_tvalid })
);

endmodule

