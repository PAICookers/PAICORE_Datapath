`resetall
`timescale 1ns / 1ps
`default_nettype none

module PAICORE_LoopBack_C2
(
    input  wire                         clk,
    input  wire                         rst,

    input  wire [31:0]                  send_len_C0,
    input  wire [31:0]                  send_len_C1,
    output wire                         o_tx_done,

    input  wire [31:0]                  oFrameNumMax,
    output wire                         o_rx_done,

    input  wire                         i_rx_rcving,

    output wire                         s00_axis_tready,
    input  wire [64-1:0]                s00_axis_tdata,
    input  wire                         s00_axis_tlast,
    input  wire                         s00_axis_tvalid,

    output wire                         s01_axis_tready,
    input  wire [64-1:0]                s01_axis_tdata,
    input  wire                         s01_axis_tlast,
    input  wire                         s01_axis_tvalid,

    input  wire                         m_axis_tready,
    output wire [64-1:0]                m_axis_tdata,
    output wire                         m_axis_tlast,
    output wire                         m_axis_tvalid

);

    wire                acknowledge_C0;
    wire     [31:0]     dout_C0;
    wire                request_C0;

    wire                acknowledge_C1;
    wire     [31:0]     dout_C1;
    wire                request_C1;

    wire                o_tx_done_C0;
    wire                o_tx_done_C1;
    reg      [1:0]      o_tx_done_reg;
    always @(posedge clk) begin
        if(rst) begin
            o_tx_done_reg <= 2'b0;
        end else if(o_rx_done) begin
            o_tx_done_reg <= 2'b0;
        end else if(o_tx_done_C0 && o_tx_done_C1) begin
            o_tx_done_reg <= 2'b10;        
        end else if(o_tx_done_C0) begin
            o_tx_done_reg <= o_tx_done_reg + 1'b1;
        end else if(o_tx_done_C1) begin
            o_tx_done_reg <= o_tx_done_reg + 1'b1;
        end
    end

    assign o_tx_done = (o_tx_done_reg == 2'b10);

    reg tx_busy_done;
    always @(posedge clk) begin
        if(rst) begin
            tx_busy_done <= 1'b0;
        end else if(o_rx_done) begin
            tx_busy_done <= 1'b0;        
        end else if(o_tx_done) begin
            tx_busy_done <= 1'b1;
        end
    end

    PAICORE_send u_PAICORE_send_C0(
        .s_axis_aclk        (clk            ),
        .s_axis_aresetn     (!rst           ),
        .send_len           (send_len_C0    ),
        .data_cnt           (),
        .tlast_cnt          (),
        .write_hsked        (),
        .write_data         (),
        .snn_in_hsked       (),
        .s_axis_tready      (s00_axis_tready),
        .s_axis_tdata       (s00_axis_tdata ),
        .s_axis_tlast       (s00_axis_tlast ),
        .s_axis_tvalid      (s00_axis_tvalid),
        .acknowledge        (acknowledge_C0 ),
        .dout               (dout_C0        ),
        .request            (request_C0     ),
        .o_tx_done          (o_tx_done_C0   )
    );

    PAICORE_send u_PAICORE_send_C1(
        .s_axis_aclk        (clk            ),
        .s_axis_aresetn     (!rst           ),
        .send_len           (send_len_C1    ),
        .data_cnt           (),
        .tlast_cnt          (),
        .write_hsked        (),
        .write_data         (),
        .snn_in_hsked       (),
        .s_axis_tready      (s01_axis_tready),
        .s_axis_tdata       (s01_axis_tdata ),
        .s_axis_tlast       (s01_axis_tlast ),
        .s_axis_tvalid      (s01_axis_tvalid),
        .acknowledge        (acknowledge_C1 ),
        .dout               (dout_C1        ),
        .request            (request_C1     ),
        .o_tx_done          (o_tx_done_C1   )
    );

    PAICORE_recv_2C u_PAICORE_recv_2C(
        .m_axis_aclk        (clk            ),
        .m_axis_aresetn     (!rst           ),
        .oFrameNumMax       (oFrameNumMax   ),
        .read_hsked         (),
        .read_data          (),
        .snn_out_hsked      (),
        .acknowledge_C0     (acknowledge_C0 ),
        .din_C0             (dout_C0        ),
        .request_C0         (request_C0     ),
        .acknowledge_C1     (acknowledge_C1 ),
        .din_C1             (dout_C1        ),
        .request_C1         (request_C1     ),
        .m_axis_tready      (m_axis_tready  ),
        .m_axis_tdata       (m_axis_tdata   ),
        .m_axis_tlast       (m_axis_tlast   ),
        .m_axis_tvalid      (m_axis_tvalid  ),
        .i_recv_done        (tx_busy_done   ),
        .i_recv_busy        (!tx_busy_done  ),
        .i_rx_rcving        (i_rx_rcving    ),
        .o_rx_done          (o_rx_done      )
    );

endmodule

`resetall