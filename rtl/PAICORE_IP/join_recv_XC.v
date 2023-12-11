`timescale 1ns / 1ps
module join_recv_XC#(
    parameter Channel = 4
)(
    input                       m_axis_aclk,
    input                       m_axis_aresetn,

    output [Channel-1:0]        acknowledge,
    input  [Channel*32-1:0]     din,
    input  [Channel-1:0]        request,

    input  [Channel-1:0]        m_axis_tready,
    output [Channel*64-1:0]     m_axis_tdata ,
    output [Channel-1:0]        m_axis_tlast ,
    output [Channel-1:0]        m_axis_tvalid
);

    wire [Channel-1:0]          fifo_tready;
    wire [Channel*64-1:0]       fifo_tdata ;
    wire [Channel-1:0]          fifo_tvalid;

    genvar i;
    generate
        for (i = 0; i < Channel; i = i + 1) begin
            req_ack_32bit_receiver u_req_ack_32bit_receiver_C1(
                .clk             (m_axis_aclk           ),
                .rstn            (m_axis_aresetn        ),
                .available       (fifo_tready[i]        ),
                .valid           (fifo_tvalid[i]        ),
                .din             (din[i*32+:32]         ),
                .request         (request[i]            ),
                .acknowledge     (acknowledge[i]        ),
                .dout            (fifo_tdata[i*64+:64]  )
            );

            axis_fifo_top #(
                .DEPTH           (16                    ),
                .DATA_WIDTH      (64                    )
            ) u_axis_fifo_top(
                .s_axis_aclk     (m_axis_aclk           ),
                .s_axis_aresetn  (m_axis_aresetn        ),
                .s_axis_tready   (fifo_tready[i]        ),
                .s_axis_tdata    (fifo_tdata[i*64+:64]  ),
                .s_axis_tlast    (1'b0                  ),
                .s_axis_tvalid   (fifo_tvalid[i]        ),
                .m_axis_tready   (m_axis_tready[i]      ),
                .m_axis_tdata    (m_axis_tdata[i*64+:64]),
                .m_axis_tlast    (m_axis_tlast[i]       ),
                .m_axis_tvalid   (m_axis_tvalid[i]      )  
            );
        end
    endgenerate

endmodule