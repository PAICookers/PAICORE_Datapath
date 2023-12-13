`timescale 1ns / 1ps
module PAICORE_send_XC#(
    parameter Channel = 4,
    parameter DATA_WIDTH = 64
)(
    input                           s_axis_aclk,
    input                           s_axis_aresetn,

    input  [Channel-1:0]            oen,

    input                           single_channel,
    input  [Channel-1:0]            single_channel_mask,
    input  [31:0]                   send_len,

    output [31:0]                   data_cnt,
    output [31:0]                   tlast_cnt,

    output                          write_hsked,
    output [63:0]                   write_data,
    output                          snn_in_hsked,

    output                          s_axis_tready,
    input [DATA_WIDTH-1:0]          s_axis_tdata,
    input                           s_axis_tlast,
    input                           s_axis_tvalid,

    input  [Channel-1:0]            acknowledge,
    output [Channel*32-1:0]         dout,
    output [Channel-1:0]            request,

    output                          o_tx_done
);

    wire                            xdma_send_tready;
    wire [DATA_WIDTH-1:0]           xdma_send_tdata ;
    wire                            xdma_send_tlast ;
    wire                            xdma_send_tvalid;

    wire                            gen_last_tready;
    wire [DATA_WIDTH-1:0]           gen_last_tdata ;
    wire                            gen_last_tlast ;
    wire                            gen_last_tvalid;

    wire [Channel-1:0]              fork_tready;
    wire [Channel*DATA_WIDTH-1:0]   fork_tdata ;
    wire [Channel-1:0]              fork_tlast ;
    wire [Channel-1:0]              fork_tvalid;

    // reset send datapath
    assign s_axis_tready    = s_axis_aresetn ? xdma_send_tready : 1'b1;
    assign xdma_send_tdata  = s_axis_tdata;
    assign xdma_send_tlast  = s_axis_tlast;
    assign xdma_send_tvalid = s_axis_aresetn ? s_axis_tvalid : 1'b0;

    axis_gen_last u_axis_gen_last(
        .s_axis_aclk        (s_axis_aclk        ),
        .s_axis_aresetn     (s_axis_aresetn     ),
        .send_len           (send_len           ),
        .data_cnt           (data_cnt           ),
        .tlast_cnt          (tlast_cnt          ),        
        .s_axis_tready      (xdma_send_tready   ),
        .s_axis_tdata       (xdma_send_tdata    ),
        .s_axis_tlast       (xdma_send_tlast    ),
        .s_axis_tvalid      (xdma_send_tvalid   ),
        .m_axis_tready      (gen_last_tready    ),
        .m_axis_tdata       (gen_last_tdata     ),
        .m_axis_tlast       (gen_last_tlast     ),
        .m_axis_tvalid      (gen_last_tvalid    ),
        .s_axis_hsked       (write_hsked        ),
        .write_data         (write_data         ) 
    );

    axis_fork_arbiter #(
        .M_COUNT            (Channel            ),
        .DATA_WIDTH         (DATA_WIDTH         )
    )u_axis_fork_arbiter(
        .clk                (s_axis_aclk        ),
        .rst                (!s_axis_aresetn    ),
        .oen                (oen                ),
        .fork_enable        (!single_channel    ),
        .single_mask        (single_channel_mask),
        .s_axis_tready      (gen_last_tready    ),
        .s_axis_tdata       (gen_last_tdata     ),
        .s_axis_tlast       (gen_last_tlast     ),
        .s_axis_tvalid      (gen_last_tvalid    ),
        .m_axis_tready      (fork_tready        ),
        .m_axis_tdata       (fork_tdata         ),
        .m_axis_tlast       (fork_tlast         ),
        .m_axis_tvalid      (fork_tvalid        )
    );

    fork_send_XC#(
        .Channel            (Channel            )
    ) u_fork_send_XC(
        .s_axis_aclk        (s_axis_aclk        ),
        .s_axis_aresetn     (s_axis_aresetn     ),
        .o_tx_done          (o_tx_done          ),
        .s_axis_tready      (fork_tready        ),
        .s_axis_tdata       (fork_tdata         ),
        .s_axis_tlast       (fork_tlast         ),
        .s_axis_tvalid      (fork_tvalid        ),
        .acknowledge        (acknowledge        ),
        .dout               (dout               ),
        .request            (request            )
    );

endmodule
