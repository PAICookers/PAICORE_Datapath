module PAICORE_top #
(
    parameter S_AXIL_DATA_WIDTH = 32,
    parameter S_AXIL_ADDR_WIDTH = 32,
    parameter S_AXIL_STRB_WIDTH = (S_AXIL_DATA_WIDTH/8),
    parameter AXIS_DATA_WIDTH   = 64,
    parameter ALL_CHANNEL       = 4,
    parameter REG_NUM           = 32
)
(
    input  wire                         s_axil_aclk,
    input  wire                         s_axil_aresetn,

    input  wire                         s_axis_aclk,
    input  wire                         s_axis_aresetn,

    input  wire                         m_axis_aclk,
    input  wire                         m_axis_aresetn,

    input  wire                         DONE,
    input  wire                         BUSY,
    output wire [2:0]                   PAICORE_CTRL,

    inout  wire [ALL_CHANNEL-1:0]       ACK,
    inout  wire [ALL_CHANNEL*32-1:0]    PDATA,
    inout  wire [ALL_CHANNEL-1:0]       REQ,
    

    input  wire [S_AXIL_ADDR_WIDTH-1:0] s_axil_awaddr,
    input  wire [2:0]                   s_axil_awprot,
    input  wire                         s_axil_awvalid,
    output wire                         s_axil_awready,

    input  wire [S_AXIL_DATA_WIDTH-1:0] s_axil_wdata,
    input  wire [S_AXIL_STRB_WIDTH-1:0] s_axil_wstrb,
    input  wire                         s_axil_wvalid,
    output wire                         s_axil_wready,

    output wire [1:0]                   s_axil_bresp,
    output wire                         s_axil_bvalid,
    input  wire                         s_axil_bready,

    input  wire [S_AXIL_ADDR_WIDTH-1:0] s_axil_araddr,
    input  wire [2:0]                   s_axil_arprot,
    input  wire                         s_axil_arvalid,
    output wire                         s_axil_arready,
    
    output wire [S_AXIL_DATA_WIDTH-1:0] s_axil_rdata,
    output wire [1:0]                   s_axil_rresp,
    output wire                         s_axil_rvalid,
    input  wire                         s_axil_rready,

    output wire                         s_axis_tready,
    input  wire [AXIS_DATA_WIDTH-1:0]   s_axis_tdata,
    input  wire                         s_axis_tlast,
    input  wire                         s_axis_tvalid,

    input  wire                         m_axis_tready,
    output wire [AXIS_DATA_WIDTH-1:0]   m_axis_tdata,
    output wire                         m_axis_tlast,
    output wire                         m_axis_tvalid

);
    wire                                tx_done;
    wire                                rx_done;
    wire                                rx_rcving;

    wire [ALL_CHANNEL-1:0]              oen;
    wire                                single_channel;
    wire [ALL_CHANNEL-1:0]              single_channel_mask;
    wire [31:0]                         send_len;
    wire [31:0]                         oFrameNumMax;

    wire [31:0]                         data_cnt;
    wire [31:0]                         tlast_cnt;

    wire                                write_hsked;
    wire [63:0]                         write_data;
    
    wire                                snn_in_hsked;
    wire                                snn_out_hsked;

    wire                                read_hsked;
    wire [63:0]                         read_data;
    
    wire  [31:0]                        us_tick_num;

    PAICORE_regfile #(
        .DATA_WIDTH         (S_AXIL_DATA_WIDTH  ),
        .ADDR_WIDTH         (S_AXIL_ADDR_WIDTH  ),
        .STRB_WIDTH         (S_AXIL_STRB_WIDTH  ),
        .All_Channel        (ALL_CHANNEL        ),
        .REG_NUM            (REG_NUM            )
    ) u_PAICORE_regfile (
        .clk                (s_axil_aclk        ),
        .rst                (~s_axil_aresetn    ),
        .i_tx_done          (tx_done            ),
        .i_rx_done          (rx_done            ),
        .o_rx_rcving        (rx_rcving          ),
        .cpu2fifo_plus      (write_hsked        ),
        .fifo2snn_plus      (snn_in_hsked       ),
        .snn2fifo_plus      (snn_out_hsked      ),
        .fifo2cpu_plus      (read_hsked         ),
        .write_data         (write_data         ),
        .read_data          (read_data          ),
        .data_cnt           (data_cnt           ),
        .tlast_cnt          (tlast_cnt          ),
        .us_tick_num        (us_tick_num        ),
        .send_len           (send_len           ),
        .oFrameNumMax       (oFrameNumMax       ),
        .PAICORE_CTRL       (PAICORE_CTRL       ),
        .DataPath_Reset_n   (                   ),
        .single_channel     (single_channel     ),
        .single_channel_mask(single_channel_mask),
        .oen                (oen                ),
        .s_axil_awaddr      (s_axil_awaddr      ),
        .s_axil_awprot      (s_axil_awprot      ),
        .s_axil_awvalid     (s_axil_awvalid     ),
        .s_axil_awready     (s_axil_awready     ),
        .s_axil_wdata       (s_axil_wdata       ),
        .s_axil_wstrb       (s_axil_wstrb       ),
        .s_axil_wvalid      (s_axil_wvalid      ),
        .s_axil_wready      (s_axil_wready      ),
        .s_axil_bresp       (s_axil_bresp       ),
        .s_axil_bvalid      (s_axil_bvalid      ),
        .s_axil_bready      (s_axil_bready      ),
        .s_axil_araddr      (s_axil_araddr      ),
        .s_axil_arprot      (s_axil_arprot      ),
        .s_axil_arvalid     (s_axil_arvalid     ),
        .s_axil_arready     (s_axil_arready     ),
        .s_axil_rdata       (s_axil_rdata       ),
        .s_axil_rresp       (s_axil_rresp       ),
        .s_axil_rvalid      (s_axil_rvalid      ),
        .s_axil_rready      (s_axil_rready      )
    );

    PAICORE_transfer#(
        .All_Channel        (ALL_CHANNEL        ),
        .DATA_WIDTH         (AXIS_DATA_WIDTH    )
    ) u_PAICORE_transfer (
        .s_axis_aclk        (s_axis_aclk        ),
        .s_axis_aresetn     (s_axis_aresetn     ),
        .m_axis_aclk        (m_axis_aclk        ),
        .m_axis_aresetn     (m_axis_aresetn     ),
        .oen                (oen                ),
        .single_channel     (single_channel     ),
        .single_channel_mask(single_channel_mask),
        .send_len           (send_len           ),
        .oFrameNumMax       (oFrameNumMax       ),
        .data_cnt           (data_cnt           ),
        .tlast_cnt          (tlast_cnt          ),
        .write_hsked        (write_hsked        ),
        .write_data         (write_data         ),
        .snn_in_hsked       (snn_in_hsked       ),
        .read_hsked         (read_hsked         ),
        .read_data          (read_data          ),
        .snn_out_hsked      (snn_out_hsked      ),
        .s_axis_tready      (s_axis_tready      ),
        .s_axis_tdata       (s_axis_tdata       ),
        .s_axis_tlast       (s_axis_tlast       ),
        .s_axis_tvalid      (s_axis_tvalid      ),
        .m_axis_tready      (m_axis_tready      ),
        .m_axis_tdata       (m_axis_tdata       ),
        .m_axis_tlast       (m_axis_tlast       ),
        .m_axis_tvalid      (m_axis_tvalid      ),
        .acknowledge        (ACK                ),
        .pdata              (PDATA              ),
        .request            (REQ                ),
        .i_recv_done        (DONE               ),
        .i_recv_busy        (BUSY               ),
        .i_rx_rcving        (rx_rcving          ),
        .o_tx_done          (tx_done            ),
        .o_rx_done          (rx_done            )
    );

    timeMeasure u_timeMeasure(
        .clk                (s_axil_aclk        ),
        .rst_n              (s_axil_aresetn     ),
        .send_done          (tx_done            ),
        .recv_done          (rx_done            ),
        .us_tick_num        (us_tick_num        )
    );

endmodule