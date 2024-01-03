`timescale 1ns / 1ps
module PAICORE_recv_XC#(
    parameter Channel = 4,
    parameter DATA_WIDTH = 64
)(
    input                       m_axis_aclk,
    input                       m_axis_aresetn,

    input  [Channel-1:0]        ien,

    input  [31:0]               oFrameNumMax,

    output                      read_hsked,
    output   [63:0]             read_data,
    output                      snn_out_hsked,

    output [Channel-1:0]        acknowledge,
    input  [Channel*32-1:0]     din,
    input  [Channel-1:0]        request,

    input                       m_axis_tready,
    output [DATA_WIDTH-1:0]     m_axis_tdata ,
    output                      m_axis_tlast ,
    output                      m_axis_tvalid,

    input                       i_recv_done,
    input                       i_recv_busy,
    input                       i_rx_rcving,
    output                      o_rx_done
);

    wire [Channel-1:0]              fifo_tready;
    wire [Channel*DATA_WIDTH-1:0]   fifo_tdata ;
    wire [Channel-1:0]              fifo_tlast ;
    wire [Channel-1:0]              fifo_tvalid;

    wire                            join_tready;
    wire [DATA_WIDTH-1:0]           join_tdata ;
    wire                            join_tvalid;

    wire                            tp_up_tready;
    wire [DATA_WIDTH-1:0]           tp_up_tdata ;
    wire                            tp_up_tlast ;
    wire                            tp_up_tvalid;

    wire                            padding_tready;
    wire [DATA_WIDTH-1:0]           padding_tdata ;
    wire                            padding_tlast ;
    wire                            padding_tvalid;

    join_recv_XC #(
        .Channel    (Channel)
    ) u_join_recv_XC(
        .m_axis_aclk    (m_axis_aclk       ),
        .m_axis_aresetn (m_axis_aresetn    ),
        .acknowledge    (acknowledge       ),
        .din            (din               ),
        .request        (request           ),
        .m_axis_tready  (fifo_tready       ), 
        .m_axis_tdata   (fifo_tdata        ),
        .m_axis_tlast   (fifo_tlast        ),
        .m_axis_tvalid  (fifo_tvalid       )
    );

    axis_join_arbiter #(
        .S_COUNT            (Channel            ),
        .DATA_WIDTH         (DATA_WIDTH         )
    ) u_axis_join_arbiter(
        .clk                (m_axis_aclk        ),
        .rst                (!m_axis_aresetn    ),
        .ien                (ien                ),
        .s_axis_tvalid      (fifo_tvalid        ),
        .s_axis_tdata       (fifo_tdata         ),
        .s_axis_tlast       (fifo_tlast         ),
        .s_axis_tready      (fifo_tready        ),
        .m_axis_tvalid      (join_tvalid        ),
        .m_axis_tdata       (join_tdata         ),
        .m_axis_tlast       (                   ),
        .m_axis_tready      (join_tready        )
    );

    transport_up u_transport_up(
        .s_axis_aclk     (m_axis_aclk           ),
        .s_axis_aresetn  (m_axis_aresetn        ),
        .s_axis_tready   (join_tready           ),
        .s_axis_tvalid   (join_tvalid           ),
        .s_axis_tdata    (join_tdata            ),
        .i_recv_done     (i_recv_done           ),
        .i_recv_busy     (i_recv_busy           ),
        .m_axis_tready   (tp_up_tready          ),
        .m_axis_tdata    (tp_up_tdata           ),
        .m_axis_tlast    (tp_up_tlast           ),
        .m_axis_tvalid   (tp_up_tvalid          ),
        .m_axis_hsked    (snn_out_hsked         ),
        .i_rx_rcving     (i_rx_rcving           ),
        .o_rx_done       (o_rx_done             )
    );

    // wrong handshake, need fix
    axis_dataPadding u_axis_dataPadding(
        .s_axis_aclk     (m_axis_aclk           ),
        .s_axis_aresetn  (m_axis_aresetn        ),
        .oFrameNumMax    (oFrameNumMax          ),
        .s_axis_tready   (tp_up_tready          ),
        .s_axis_tdata    (tp_up_tdata           ),
        .s_axis_tlast    (tp_up_tlast           ),
        .s_axis_tvalid   (tp_up_tvalid          ),
        .m_axis_tready   (padding_tready        ),
        .m_axis_tdata    (padding_tdata         ),
        .m_axis_tlast    (padding_tlast         ),
        .m_axis_tvalid   (padding_tvalid        ),
        .m_axis_hsked    (read_hsked            ),
        .read_data       (read_data             )
    );

    axis_fifo_top #(
        .DEPTH           (16                ),
        .DATA_WIDTH      (DATA_WIDTH        )
    )  u_axis_fifo_top(
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