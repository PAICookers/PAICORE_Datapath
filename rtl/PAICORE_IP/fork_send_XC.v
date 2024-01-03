`timescale 1ns / 1ps
module fork_send_XC#(
    parameter Channel = 4
)(
    input                       s_axis_aclk,
    input                       s_axis_aresetn,

    output                      o_tx_done,
    
    output [Channel-1:0]        s_axis_tready,
    input  [Channel*64-1:0]     s_axis_tdata ,
    input  [Channel-1:0]        s_axis_tlast ,
    input  [Channel-1:0]        s_axis_tvalid,

    input  [Channel-1:0]        acknowledge,
    output [Channel*32-1:0]     dout,
    output [Channel-1:0]        request
);

    wire [Channel-1:0]          fifo_tready;
    wire [Channel*64-1:0]       fifo_tdata ;
    wire [Channel-1:0]          fifo_tlast ;
    wire [Channel-1:0]          fifo_tvalid;

    wire [Channel-1:0]          drop_tready;
    wire [Channel*64-1:0]       drop_tdata ;
    wire [Channel-1:0]          drop_tlast ;
    wire [Channel-1:0]          drop_tvalid;

    genvar i;
    generate
        for (i = 0; i < Channel; i = i + 1) begin
            axis_fifo_top #(
                .DEPTH           (16                    ),
                .DATA_WIDTH      (64                    )
            ) u_axis_fifo_top(
                .s_axis_aclk     (s_axis_aclk           ),
                .s_axis_aresetn  (s_axis_aresetn        ),
                .s_axis_tready   (s_axis_tready[i]      ),
                .s_axis_tdata    (s_axis_tdata[i*64+:64]),
                .s_axis_tlast    (s_axis_tlast[i]       ),
                .s_axis_tvalid   (s_axis_tvalid[i]      ),
                .m_axis_tready   (fifo_tready[i]        ),
                .m_axis_tdata    (fifo_tdata[i*64+:64]  ),
                .m_axis_tlast    (fifo_tlast[i]         ),
                .m_axis_tvalid   (fifo_tvalid[i]        )  
            );

            axis_dropData #(
                .DATA_WIDTH      (64                    )
            ) u_axis_dropData(
                .clk             (s_axis_aclk           ),
                .rst             (!s_axis_aresetn       ),
                .s_axis_tready   (fifo_tready[i]        ),
                .s_axis_tdata    (fifo_tdata[i*64+:64]  ),
                .s_axis_tlast    (fifo_tlast[i]         ),
                .s_axis_tvalid   (fifo_tvalid[i]        ),
                .m_axis_tready   (drop_tready[i]        ),
                .m_axis_tdata    (drop_tdata[i*64+:64]  ),
                .m_axis_tlast    (drop_tlast[i]         ),
                .m_axis_tvalid   (drop_tvalid[i]        )
            );

            req_ack_32bit_sender u_req_ack_32bit_sender(
                .clk             (s_axis_aclk           ),
                .rstn            (s_axis_aresetn        ),
                .available       (drop_tready[i]        ),
                .valid           (drop_tvalid[i]        ),
                .din             (drop_tdata[i*64+:64]  ),
                .request         (request[i]            ),
                .acknowledge     (acknowledge[i]        ),
                .dout            (dout[i*32+:32]        )
            );
        end
    endgenerate

    reg [Channel-1:0] o_tx_done_flag;
    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            o_tx_done_flag <= {Channel{1'b0}};
        end else if(o_tx_done) begin
            o_tx_done_flag <= {Channel{1'b0}};
        end else begin
            o_tx_done_flag <= o_tx_done_flag | (s_axis_tready & s_axis_tvalid & s_axis_tlast);
        end
    end

    assign o_tx_done = &o_tx_done_flag;

endmodule
