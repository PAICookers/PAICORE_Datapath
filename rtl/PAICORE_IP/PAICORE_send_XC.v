module PAICORE_send_XC#(
    parameter Channel = 4,
    parameter DATA_WIDTH = 64
)(
    input                           s_axis_aclk,
    input                           s_axis_aresetn,

    input                           fork_enable,
    input      [31:0]               send_len,

    output                          s_axis_tready,
    input      [DATA_WIDTH-1:0]     s_axis_tdata,
    input                           s_axis_tlast,
    input                           s_axis_tvalid,

    input  [Channel-1:0]            acknowledge,
    output [Channel*32-1:0]         dout,
    output [Channel-1:0]            request,

    output                          o_tx_done
);

    wire                            gen_last_tready;
    wire [DATA_WIDTH-1:0]           gen_last_tdata ;
    wire                            gen_last_tlast ;
    wire                            gen_last_tvalid;

    wire [Channel-1:0]              fork_tready;
    wire [Channel*DATA_WIDTH-1:0]   fork_tdata ;
    wire [Channel-1:0]              fork_tlast ;
    wire [Channel-1:0]              fork_tvalid;

    axis_gen_last u_axis_gen_last(
        .s_axis_aclk        (s_axis_aclk        ),
        .s_axis_aresetn     (s_axis_aresetn     ),
        .send_len           (send_len           ),
        .s_axis_tready      (s_axis_tready      ),
        .s_axis_tdata       (s_axis_tdata       ),
        .s_axis_tlast       (s_axis_tlast       ),
        .s_axis_tvalid      (s_axis_tvalid      ),
        .m_axis_tready      (gen_last_tready    ),
        .m_axis_tdata       (gen_last_tdata     ),
        .m_axis_tlast       (gen_last_tlast     ),
        .m_axis_tvalid      (gen_last_tvalid    )
    );

    axis_fork_arbiter #(
        .M_COUNT            (Channel            ),
        .DATA_WIDTH         (DATA_WIDTH         )
    )u_axis_fork_arbiter(
        .clk                (s_axis_aclk        ),
        .rst                (!s_axis_aresetn    ),
        .fork_enable        (fork_enable        ),
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
