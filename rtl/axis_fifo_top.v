
`resetall
`timescale 1ns / 1ps
`default_nettype none

module axis_fifo_top #
(
    parameter DEPTH = 512,
    parameter DATA_WIDTH = 64
)
(
    input  wire                   s_axis_aclk,
    input  wire                   s_axis_aresetn,

    /*
     * AXI input
     */
    output wire                   s_axis_tready,
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire                   s_axis_tvalid,
    
    input  wire                   m_axis_tready,
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output  wire                  m_axis_tlast,
    output wire                   m_axis_tvalid
);

    axis_fifo #
    (
        .DEPTH                  (DEPTH              ),
        .DATA_WIDTH             (DATA_WIDTH         ),
        .KEEP_ENABLE            (DATA_WIDTH>8       ),
        .KEEP_WIDTH             ((DATA_WIDTH+7)/8   ),
        .LAST_ENABLE            (1                  ),
        .ID_ENABLE              (0                  ),
        .ID_WIDTH               (8                  ),
        .DEST_ENABLE            (0                  ),
        .DEST_WIDTH             (8                  ),
        .USER_ENABLE            (0                  ),
        .USER_WIDTH             (1                  ),
        .RAM_PIPELINE           (1                  ),
        .OUTPUT_FIFO_ENABLE     (0                  ),
        .FRAME_FIFO             (0                  ),
        .USER_BAD_FRAME_VALUE   (1'b1               ),
        .USER_BAD_FRAME_MASK    (1'b1               ),
        .DROP_OVERSIZE_FRAME    (0                  ),
        .DROP_BAD_FRAME         (0                  ),
        .DROP_WHEN_FULL         (0                  ),
        .MARK_WHEN_FULL         (0                  ),
        .PAUSE_ENABLE           (0                  ),
        .FRAME_PAUSE            (0                  )
    )
    u_axis_fifo (
        .clk                (s_axis_aclk    ),
        .rst                (!s_axis_aresetn),
        .s_axis_tdata       (s_axis_tdata   ),
        .s_axis_tkeep       (8'b11111111    ),
        .s_axis_tvalid      (s_axis_tvalid  ),
        .s_axis_tready      (s_axis_tready  ),
        .s_axis_tlast       (s_axis_tlast   ),
        .s_axis_tid         (8'b0           ),
        .s_axis_tdest       (8'b0           ),
        .s_axis_tuser       (1'b0           ),
        .m_axis_tdata       (m_axis_tdata   ),
        .m_axis_tkeep       (               ),
        .m_axis_tvalid      (m_axis_tvalid  ),
        .m_axis_tready      (m_axis_tready  ),
        .m_axis_tlast       (m_axis_tlast   ),
        .m_axis_tid         (               ),
        .m_axis_tdest       (               ),
        .m_axis_tuser       (               ),
        .pause_req          (1'b0           ),
        .pause_ack          (               ),
        .status_depth       (               ),
        .status_depth_commit(               ),
        .status_overflow    (               ),
        .status_bad_frame   (               ),
        .status_good_frame  (               )
    );


endmodule

`resetall