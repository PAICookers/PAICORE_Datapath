`timescale 1ns / 1ps
module fork_send(
    input               s_axis_aclk,
    input               s_axis_aresetn,

    input      [31:0]   send_len,
    output     [31:0]   data_cnt,
    output     [31:0]   tlast_cnt,

    output              write_hsked,
    output     [63:0]   write_data,
    output              snn_in_hsked,

    output              s_axis_tready,
    input      [63:0]   s_axis_tdata,
    input               s_axis_tlast,
    input               s_axis_tvalid,

    input               acknowledge,
    output     [31:0]   dout,
    output              request,

    output              o_tx_done
);

    wire                gen_last_tready;
    wire     [63:0]     gen_last_tdata ;
    wire                gen_last_tlast ;
    wire                gen_last_tvalid;

    wire                sender_available;
    wire                sender_valid;
    wire     [63:0]     sender_data;

    axis_gen_last u_axis_gen_last(
        .s_axis_aclk     (s_axis_aclk       ),
        .s_axis_aresetn  (s_axis_aresetn    ),
        .send_len        (send_len          ),
        .data_cnt        (data_cnt          ),
        .tlast_cnt       (tlast_cnt         ),
        .s_axis_tready   (s_axis_tready     ),
        .s_axis_tdata    (s_axis_tdata      ),
        .s_axis_tlast    (s_axis_tlast      ),
        .s_axis_tvalid   (s_axis_tvalid     ),
        .m_axis_tready   (gen_last_tready   ),
        .m_axis_tdata    (gen_last_tdata    ),
        .m_axis_tlast    (gen_last_tlast    ),
        .m_axis_tvalid   (gen_last_tvalid   ),
        .s_axis_hsked    (write_hsked       ),
        .write_data      (write_data        ) 
    );

    transport_down u_transport_down(
        .s_axis_aclk     (s_axis_aclk       ),
        .s_axis_aresetn  (s_axis_aresetn    ),
        .s_axis_tready   (gen_last_tready   ),
        .s_axis_tdata    (gen_last_tdata    ),
        .s_axis_tlast    (gen_last_tlast    ),
        .s_axis_tvalid   (gen_last_tvalid   ),
        .i_send_available(sender_available  ),
        .o_send_valid    (sender_valid      ),
        .o_send_pdata    (sender_data       ),
        .s_axis_hsked    (snn_in_hsked      ),
        .o_tx_done       (o_tx_done         )
    );

    req_ack_32bit_sender u_req_ack_32bit_sender(
        .clk             (s_axis_aclk       ),
        .rstn            (s_axis_aresetn    ),
        .available       (sender_available  ),
        .valid           (sender_valid      ),
        .din             (sender_data       ),
        .request         (request           ),
        .acknowledge     (acknowledge       ),
        .dout            (dout              )
    );

endmodule
