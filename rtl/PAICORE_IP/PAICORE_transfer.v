`timescale 1ns / 1ps
module PAICORE_transfer#(
    parameter All_Channel = 4,
    parameter DATA_WIDTH  = 64
)(
    input                           s_axis_aclk,
    input                           s_axis_aresetn,

    input                           m_axis_aclk,
    input                           m_axis_aresetn,

    input  [All_Channel-1:0]        oen,
    
    input                           single_channel,
    input  [All_Channel-1:0]        single_channel_mask,
    input      [31:0]               send_len,

    input      [31:0]               oFrameNumMax,

    output     [31:0]               data_cnt,
    output     [31:0]               tlast_cnt,

    output                          write_hsked,
    output     [63:0]               write_data,
    output                          snn_in_hsked,

    output                          read_hsked,
    output     [63:0]               read_data,
    output                          snn_out_hsked,

    output                          s_axis_tready,
    input  [DATA_WIDTH-1:0]         s_axis_tdata,
    input                           s_axis_tlast,
    input                           s_axis_tvalid,

    input                           m_axis_tready,
    output [DATA_WIDTH-1:0]         m_axis_tdata ,
    output                          m_axis_tlast ,
    output                          m_axis_tvalid,

    inout  [All_Channel-1:0]        acknowledge,
    inout  [All_Channel*32-1:0]     pdata,
    inout  [All_Channel-1:0]        request,

    input                           i_recv_done,
    input                           i_recv_busy,
    input                           i_rx_rcving,
    output                          o_tx_done,
    output                          o_rx_done
);

    wire [All_Channel-1:0]        ACK_SEND;
    wire [All_Channel*32-1:0]     DAT_SEND;
    wire [All_Channel-1:0]        REQ_SEND;

    wire [All_Channel-1:0]        ACK_RECV;
    wire [All_Channel*32-1:0]     DAT_RECV;
    wire [All_Channel-1:0]        REQ_RECV;

    PAICORE_send_XC #(
        .Channel            (All_Channel        ),
        .DATA_WIDTH         (DATA_WIDTH         )
    ) u_PAICORE_send_XC(
        .s_axis_aclk        (s_axis_aclk        ),
        .s_axis_aresetn     (s_axis_aresetn     ),
        .oen                (oen                ),
        .single_channel     (single_channel     ),
        .single_channel_mask(single_channel_mask),
        .send_len           (send_len           ),
        .data_cnt           (data_cnt           ),
        .tlast_cnt          (tlast_cnt          ),
        .write_hsked        (write_hsked        ),
        .write_data         (write_data         ),
        .snn_in_hsked       (snn_in_hsked       ),
        .s_axis_tready      (s_axis_tready      ),
        .s_axis_tdata       (s_axis_tdata       ),
        .s_axis_tlast       (s_axis_tlast       ),
        .s_axis_tvalid      (s_axis_tvalid      ),
        .acknowledge        (ACK_SEND           ),
        .dout               (DAT_SEND           ),
        .request            (REQ_SEND           ),
        .o_tx_done          (o_tx_done          )
    );

    PAICORE_recv_XC #(
        .Channel            (All_Channel    ),
        .DATA_WIDTH         (DATA_WIDTH     )
    ) u_PAICORE_recv_XC(
        .m_axis_aclk        (m_axis_aclk    ),
        .m_axis_aresetn     (m_axis_aresetn ),
        .ien                (~oen           ),
        .oFrameNumMax       (oFrameNumMax   ),
        .read_hsked         (read_hsked     ),
        .read_data          (read_data      ),
        .snn_out_hsked      (snn_out_hsked  ),
        .acknowledge        (ACK_RECV       ),
        .din                (DAT_RECV       ),
        .request            (REQ_RECV       ),
        .m_axis_tready      (m_axis_tready  ),
        .m_axis_tdata       (m_axis_tdata   ),
        .m_axis_tlast       (m_axis_tlast   ),
        .m_axis_tvalid      (m_axis_tvalid  ),
        .i_recv_done        (i_recv_done    ),
        .i_recv_busy        (i_recv_busy    ),
        .i_rx_rcving        (i_rx_rcving    ),
        .o_rx_done          (o_rx_done      )
    );

    transfer_io_ctrl#(
        .All_Channel        (All_Channel    )
    ) u_transfer_io_ctrl(
        .clk                (s_axis_aclk    ),
        .rst                (!s_axis_aresetn),
        .oen                (oen            ),
        .acknowledge        (acknowledge    ),
        .pdata              (pdata          ),
        .request            (request        ),
        .ACK_SEND           (ACK_SEND       ),
        .DAT_SEND           (DAT_SEND       ),
        .REQ_SEND           (REQ_SEND       ),
        .ACK_RECV           (ACK_RECV       ),
        .DAT_RECV           (DAT_RECV       ),
        .REQ_RECV           (REQ_RECV       )
    );

endmodule