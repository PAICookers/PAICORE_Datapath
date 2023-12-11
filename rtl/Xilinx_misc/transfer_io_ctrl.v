`timescale 1ns / 1ps
module transfer_io_ctrl#(
    parameter All_Channel = 4
)(
    input                           clk,
    input                           rst,

    input  [All_Channel-1:0]        oen,

    inout  [All_Channel-1:0]        acknowledge,
    inout  [All_Channel*32-1:0]     pdata,
    inout  [All_Channel-1:0]        request,

    output [All_Channel-1:0]        ACK_SEND,
    input  [All_Channel*32-1:0]     DAT_SEND,
    input  [All_Channel-1:0]        REQ_SEND,

    input  [All_Channel-1:0]        ACK_RECV,
    output [All_Channel*32-1:0]     DAT_RECV,
    output [All_Channel-1:0]        REQ_RECV
);

    wire [All_Channel-1:0]          ack_o;
    wire [All_Channel*32-1:0]       dat_o;
    wire [All_Channel-1:0]          req_o;

    reg  [All_Channel-1:0]          ack_o_reg;
    reg  [All_Channel*32-1:0]       dat_o_reg;
    reg  [All_Channel-1:0]          req_o_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ack_o_reg <= {All_Channel{1'b0}};
            dat_o_reg <= {All_Channel*32{1'b0}};
            req_o_reg <= {All_Channel{1'b0}};
        end else begin
            ack_o_reg <= ack_o;
            dat_o_reg <= dat_o;
            req_o_reg <= req_o;
        end
    end

    assign ACK_SEND = ack_o_reg;
    assign DAT_RECV = dat_o_reg;
    assign REQ_RECV = req_o_reg;

    genvar i;
    genvar j;
    generate 
        for (i = 0; i < All_Channel; i = i + 1) begin 
            IOBUF #(
                .DRIVE                          (12                 ), // Specify the output drive strength
                .IOSTANDARD                     ("DEFAULT"          ), // Specify the I/O standard
                .SLEW                           ("SLOW"             )  // Specify the output slew rate
            ) ACK_IOBUF_inst (
                .O                              ( ack_o[i]          ), // Buffer output
                .IO                             ( acknowledge[i]    ), // Buffer inout port (connect directly to top-level port)
                .I                              ( ACK_RECV[i]       ), // Buffer input
                .T                              ( oen[i]            )  // 3-state enable input, high=input, low=output
            );
        end
    endgenerate

    generate
        for (i = 0; i < All_Channel; i = i + 1) begin 
            IOBUF #(
                .DRIVE                          (12                 ), // Specify the output drive strength
                .IOSTANDARD                     ("DEFAULT"          ), // Specify the I/O standard
                .SLEW                           ("SLOW"             )  // Specify the output slew rate
            ) REQ_IOBUF_inst (
                .O                              ( req_o[i]          ), // Buffer output
                .IO                             ( request[i]        ), // Buffer inout port (connect directly to top-level port)
                .I                              ( REQ_SEND[i]       ), // Buffer input
                .T                              ( oen[i]            )  // 3-state enable input, high=input, low=output
            );
        end
    endgenerate

    generate 
        for (i = 0; i < All_Channel; i = i + 1) begin 
            for (j = 0; j < 32; j = j + 1) begin 
                IOBUF #(
                    .DRIVE                          (12                 ), // Specify the output drive strength
                    .IOSTANDARD                     ("DEFAULT"          ), // Specify the I/O standard
                    .SLEW                           ("SLOW"             )  // Specify the output slew rate
                ) REQ_IOBUF_inst (
                    .O                              ( dat_o[i*32+j]     ), // Buffer output
                    .IO                             ( pdata[i*32+j]     ), // Buffer inout port (connect directly to top-level port)
                    .I                              ( DAT_SEND[i*32+j]  ), // Buffer input
                    .T                              ( oen[i]            )  // 3-state enable input, high=input, low=output
                );
            end
        end
    endgenerate

endmodule