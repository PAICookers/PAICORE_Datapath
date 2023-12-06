module PAICORE_recv_2C(
    input               m_axis_aclk,
    input               m_axis_aresetn,

    input    [31:0]     oFrameNumMax,

    output              read_hsked,
    output   [63:0]     read_data,
    output              snn_out_hsked,

    output              acknowledge_C0,
    input    [31:0]     din_C0,
    input               request_C0,

    output              acknowledge_C1,
    input    [31:0]     din_C1,
    input               request_C1,

    input               m_axis_tready,
    output   [63:0]     m_axis_tdata ,
    output              m_axis_tlast ,
    output              m_axis_tvalid,

    input               i_recv_done,
    input               i_recv_busy,
    input               i_rx_rcving,
    output              o_rx_done
);

    wire                recver_available_C0;
    wire                recver_valid_C0;
    wire     [63:0]     recver_data_C0;

    wire                recver_available_C1;
    wire                recver_valid_C1;
    wire     [63:0]     recver_data_C1;

    wire                fifo_C0_tready;
    wire     [63:0]     fifo_C0_tdata ;
    wire                fifo_C0_tvalid;

    wire                fifo_C1_tready;
    wire     [63:0]     fifo_C1_tdata ;
    wire                fifo_C1_tvalid;

    wire                tp_up_tready;
    wire     [63:0]     tp_up_tdata ;
    wire                tp_up_tlast ;
    wire                tp_up_tvalid;

    wire                mux_tready;
    wire     [63:0]     mux_tdata ;
    wire                mux_tlast ;
    wire                mux_tvalid;

    wire                padding_tready;
    wire     [63:0]     padding_tdata ;
    wire                padding_tlast ;
    wire                padding_tvalid;

    req_ack_32bit_receiver u_req_ack_32bit_receiver_C0(
        .clk             (m_axis_aclk           ),
        .rstn            (m_axis_aresetn        ),
        .available       (recver_available_C0   ),
        .valid           (recver_valid_C0       ),
        .din             (din_C0                ),
        .request         (request_C0            ),
        .acknowledge     (acknowledge_C0        ),
        .dout            (recver_data_C0        )
    );

    req_ack_32bit_receiver u_req_ack_32bit_receiver_C1(
        .clk             (m_axis_aclk           ),
        .rstn            (m_axis_aresetn        ),
        .available       (recver_available_C1   ),
        .valid           (recver_valid_C1       ),
        .din             (din_C1                ),
        .request         (request_C1            ),
        .acknowledge     (acknowledge_C1        ),
        .dout            (recver_data_C1        )
    );

    axis_fifo_top u_axis_fifo_top_C0(
        .s_axis_aclk     (m_axis_aclk           ),
        .s_axis_aresetn  (m_axis_aresetn        ),
        .s_axis_tready   (recver_available_C0   ),
        .s_axis_tdata    (recver_data_C0        ),
        .s_axis_tlast    (1'b1                  ),
        .s_axis_tvalid   (recver_valid_C0       ),
        .m_axis_tready   (fifo_C0_tready        ),
        .m_axis_tdata    (fifo_C0_tdata         ),
        .m_axis_tlast    (                      ),
        .m_axis_tvalid   (fifo_C0_tvalid        )  
    );

    axis_fifo_top u_axis_fifo_top_C1(
        .s_axis_aclk     (m_axis_aclk           ),
        .s_axis_aresetn  (m_axis_aresetn        ),
        .s_axis_tready   (recver_available_C1   ),
        .s_axis_tdata    (recver_data_C1        ),
        .s_axis_tlast    (1'b1                  ),
        .s_axis_tvalid   (recver_valid_C1       ),
        .m_axis_tready   (fifo_C1_tready        ),
        .m_axis_tdata    (fifo_C1_tdata         ),
        .m_axis_tlast    (                      ),
        .m_axis_tvalid   (fifo_C1_tvalid        )  
    );

    axis_join #(
        .DATA_WD            (64                 )
    ) u_axis_join(
        .clk                (m_axis_aclk        ),
        .rst                (!m_axis_aresetn    ),
        .s00_axis_tvalid    (fifo_C0_tvalid     ),
        .s00_axis_tdata     (fifo_C0_tdata      ),
        .s00_axis_tready    (fifo_C0_tready     ),
        .s01_axis_tvalid    (fifo_C1_tvalid     ),
        .s01_axis_tdata     (fifo_C1_tdata      ),
        .s01_axis_tready    (fifo_C1_tready     ),
        .m_axis_tvalid      (mux_tvalid         ),
        .m_axis_tdata       (mux_tdata          ),
        .m_axis_tready      (mux_tready         )
    );

   

    transport_up u_transport_up_C0(
        .s_axis_aclk     (m_axis_aclk           ),
        .s_axis_aresetn  (m_axis_aresetn        ),
        .o_recv_available(mux_tready            ),
        .i_recv_valid    (mux_tvalid            ),
        .i_recv_tdata    (mux_tdata             ),
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



    //  axis_frame_join_wrap_2 #
    //     (
    //         .DATA_WIDTH         (64         ),
    //         .TAG_ENABLE         (0          )
    //     ) U_axis_frame_join_wrap_2(
    //         .clk                (m_axis_aclk        ),
    //         .rst                (!m_axis_aresetn    ),
    //         .s00_axis_tdata     (recver_data_C0     ),
    //         .s00_axis_tvalid    (recver_valid_C0    ),
    //         .s00_axis_tready    (recver_available_C0),
    //         .s00_axis_tlast     (1'b1               ),
    //         .s00_axis_tuser     (1'b0               ),
    //         .s01_axis_tdata     (recver_data_C1     ),
    //         .s01_axis_tvalid    (recver_valid_C1    ),
    //         .s01_axis_tready    (recver_available_C1),
    //         .s01_axis_tlast     (1'b1               ),
    //         .s01_axis_tuser     (1'b0               ),
    //         .m_axis_tdata       (mux_tdata          ),
    //         .m_axis_tvalid      (mux_tvalid         ),
    //         .m_axis_tready      (mux_tready         ),
    //         .m_axis_tlast       (                   ),
    //         .m_axis_tuser       (                   ),
    //         .tag                (128'b0             ),
    //         .busy               (                   )
    //     );

    // axis_arb_mux_wrap_2  #
    // (
    //     .DATA_WIDTH             (64                 ),
    //     .ID_ENABLE              (0                  ),
    //     .S_ID_WIDTH             (8                  ),
    //     .DEST_ENABLE            (0                  ),
    //     .DEST_WIDTH             (8                  ),
    //     .USER_ENABLE            (0                  ),
    //     .USER_WIDTH             (1                  ),
    //     .LAST_ENABLE            (1                  ),
    //     .UPDATE_TID             (0                  ),
    //     .ARB_TYPE_ROUND_ROBIN   (0                  ),
    //     .ARB_LSB_HIGH_PRIORITY  (1                  )
    // ) u_axis_arb_mux_wrap_2(
    //     .clk                    (m_axis_aclk        ), 
    //     .rst                    (!m_axis_aresetn    ), 
    //     .s00_axis_tdata         (tp_up_tdata_C0     ), 
    //     .s00_axis_tkeep         (8'b11111111        ), 
    //     .s00_axis_tvalid        (tp_up_tvalid_C0    ), 
    //     .s00_axis_tready        (tp_up_tready_C0    ), 
    //     .s00_axis_tlast         (tp_up_tlast_C0     ), 
    //     .s00_axis_tid           (8'b0               ), 
    //     .s00_axis_tdest         (8'b0               ), 
    //     .s00_axis_tuser         (1'b0               ), 
    //     .s01_axis_tdata         (tp_up_tdata_C1     ), 
    //     .s01_axis_tkeep         (8'b11111111        ), 
    //     .s01_axis_tvalid        (tp_up_tvalid_C1    ), 
    //     .s01_axis_tready        (tp_up_tready_C1    ), 
    //     .s01_axis_tlast         (tp_up_tlast_C1     ), 
    //     .s01_axis_tid           (8'b0               ), 
    //     .s01_axis_tdest         (8'b0               ), 
    //     .s01_axis_tuser         (1'b0               ), 
    //     .m_axis_tdata           (mux_tdata          ), 
    //     .m_axis_tkeep           (), 
    //     .m_axis_tvalid          (mux_tvalid         ), 
    //     .m_axis_tready          (mux_tready         ), 
    //     .m_axis_tlast           (mux_tlast          ), 
    //     .m_axis_tid             (), 
    //     .m_axis_tdest           (), 
    //     .m_axis_tuser           ()
    // );