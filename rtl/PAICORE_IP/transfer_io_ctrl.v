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

    genvar i;
    genvar j;
    generate 
        for (i = 0; i < All_Channel; i = i + 1) begin 
            IOBUF #(
                .DRIVE                          (12                 ), // Specify the output drive strength
                .IOSTANDARD                     ("DEFAULT"          ), // Specify the I/O standard
                .SLEW                           ("SLOW"             )  // Specify the output slew rate
            ) ACK_IOBUF_inst (
                .O                              ( ACK_SEND[i]       ), // Buffer output
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
                .O                              ( REQ_RECV[i]       ), // Buffer output
                .IO                             ( request[i]        ), // Buffer inout port (connect directly to top-level port)
                .I                              ( REQ_SEND[i]       ), // Buffer input
                .T                              ( !oen[i]           )  // 3-state enable input, high=input, low=output
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
                    .O                              ( DAT_RECV[i*32+j]  ), // Buffer output
                    .IO                             ( pdata[i*32+j]     ), // Buffer inout port (connect directly to top-level port)
                    .I                              ( DAT_SEND[i*32+j]  ), // Buffer input
                    .T                              ( !oen[i]           )  // 3-state enable input, high=input, low=output
                );
            end
        end
    endgenerate

endmodule