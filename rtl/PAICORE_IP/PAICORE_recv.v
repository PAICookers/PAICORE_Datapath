`timescale 1ns / 1ps
module PAICORE_recv(
    input               m_axis_aclk,
    input               m_axis_aresetn,

    input    [31:0]     oFrameNumMax,

    output              read_hsked,
    output     [63:0]   read_data,
    output              snn_out_hsked,

    output              acknowledge,
    input    [31:0]     din,
    input               request,

    input               m_axis_tready,
    output   [63:0]     m_axis_tdata ,
    output              m_axis_tlast ,
    output              m_axis_tvalid,

    input               i_recv_done,
    input               i_recv_busy,
    input               i_rx_rcving,
    output              o_rx_done
);

    wire                recver_available;
    wire                recver_valid;
    wire     [63:0]     recver_data;

    wire                tp_up_tready;
    wire     [63:0]     tp_up_tdata ;
    wire                tp_up_tlast ;
    wire                tp_up_tvalid;

    wire                padding_tready;
    wire     [63:0]     padding_tdata ;
    wire                padding_tlast ;
    wire                padding_tvalid;

    req_ack_32bit_receiver u_req_ack_32bit_receiver(
        .clk             (m_axis_aclk       ),
        .rstn            (m_axis_aresetn    ),
        .available       (recver_available  ),
        .valid           (recver_valid      ),
        .din             (din               ),
        .request         (request           ),
        .acknowledge     (acknowledge       ),
        .dout            (recver_data       )
    );

    transport_up u_transport_up(
        .s_axis_aclk     (m_axis_aclk       ),
        .s_axis_aresetn  (m_axis_aresetn    ),
        .o_recv_available(recver_available  ),
        .i_recv_valid    (recver_valid      ),
        .i_recv_tdata    (recver_data       ),
        .i_recv_done     (i_recv_done       ),
        .i_recv_busy     (i_recv_busy       ),
        .m_axis_tready   (tp_up_tready      ),
        .m_axis_tdata    (tp_up_tdata       ),
        .m_axis_tlast    (tp_up_tlast       ),
        .m_axis_tvalid   (tp_up_tvalid      ),
        .m_axis_hsked    (snn_out_hsked     ),
        .i_rx_rcving     (i_rx_rcving       ),
        .o_rx_done       (o_rx_done         )
    );

    axis_dataPadding u_axis_dataPadding(
        .s_axis_aclk     (m_axis_aclk       ),
        .s_axis_aresetn  (m_axis_aresetn    ),
        .oFrameNumMax    (oFrameNumMax      ),
        .s_axis_tready   (tp_up_tready      ),
        .s_axis_tdata    (tp_up_tdata       ),
        .s_axis_tlast    (tp_up_tlast       ),
        .s_axis_tvalid   (tp_up_tvalid      ),
        .m_axis_tready   (padding_tready    ),
        .m_axis_tdata    (padding_tdata     ),
        .m_axis_tlast    (padding_tlast     ),
        .m_axis_tvalid   (padding_tvalid    ),
        .m_axis_hsked    (read_hsked        ),
        .read_data       (read_data         )
    );

    axis_fifo_top u_axis_fifo_top(
        .s_axis_aclk     (m_axis_aclk       ),
        .s_axis_aresetn  (m_axis_aresetn    ),
        .s_axis_tready   (padding_tready    ),
        .s_axis_tdata    (padding_tdata     ),
        .s_axis_tlast    (padding_tlast     ),
        .s_axis_tvalid   (padding_tvalid    ),
        .m_axis_tready   (m_axis_tready     ),
        .m_axis_tdata    (m_axis_tdata      ),
        .m_axis_tlast    (m_axis_tlast      ),
        .m_axis_tvalid   (m_axis_tvalid     )  
    );

endmodule
