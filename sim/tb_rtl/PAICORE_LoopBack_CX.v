`timescale 1ns / 1ps
module PAICORE_LoopBack_CX#(
    parameter Channel = 2,
    parameter DATA_WIDTH = 64
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire                         single_channel,
    input  wire [Channel-1:0]           single_channel_mask,
    input  wire [31:0]                  send_len,
    output wire                         o_tx_done,

    input  wire [31:0]                  oFrameNumMax,
    output wire                         o_rx_done,

    input  wire                         i_rx_rcving,

    output wire                         s_axis_tready,
    input  wire [DATA_WIDTH-1:0]        s_axis_tdata ,
    input  wire                         s_axis_tlast ,
    input  wire                         s_axis_tvalid,

    input  wire                         m_axis_tready,
    output wire [DATA_WIDTH-1:0]        m_axis_tdata ,
    output wire                         m_axis_tlast ,
    output wire                         m_axis_tvalid

);

    wire [Channel-1:0]            acknowledge;
    wire [Channel*32-1:0]         dout;
    wire [Channel-1:0]            request;

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
    
    PAICORE_send_XC #(
        .Channel            (Channel            ),
        .DATA_WIDTH         (DATA_WIDTH         )
    ) u_PAICORE_send_XC(
        .s_axis_aclk        (clk                ),
        .s_axis_aresetn     (!rst               ),
        .single_channel     (single_channel     ),
        .single_channel_mask(single_channel_mask),
        .send_len           (send_len           ),
        
        .data_cnt           (                   ),
        .tlast_cnt          (                   ),
        .write_hsked        (                   ),
        .write_data         (                   ),
        .snn_in_hsked       (                   ),

        .s_axis_tready      (s_axis_tready      ),
        .s_axis_tdata       (s_axis_tdata       ),
        .s_axis_tlast       (s_axis_tlast       ),
        .s_axis_tvalid      (s_axis_tvalid      ),
        .acknowledge        (acknowledge        ),
        .dout               (dout               ),
        .request            (request            ),
        .o_tx_done          (o_tx_done          )
    );

    PAICORE_recv_XC #(
        .Channel            (Channel        ),
        .DATA_WIDTH         (DATA_WIDTH     )
    ) u_PAICORE_recv_XC(
        .m_axis_aclk        (clk            ),
        .m_axis_aresetn     (!rst           ),
        .oFrameNumMax       (oFrameNumMax   ),

        .read_hsked         (               ),
        .read_data          (               ),
        .snn_out_hsked      (               ),

        .acknowledge        (acknowledge    ),
        .din                (dout           ),
        .request            (request        ),
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