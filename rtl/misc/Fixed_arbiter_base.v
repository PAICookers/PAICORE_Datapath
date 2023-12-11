`timescale 1ns / 1ps
// input base priority
module Fixed_arbiter_base#(
    parameter NUM_REQ = 4
)(
    input                   arb_enable,
    input  [NUM_REQ-1:0]    single_mask,
    input  [NUM_REQ-1:0]    base,
    input  [NUM_REQ-1:0]    request,
    output [NUM_REQ-1:0]    grant
);
    
    wire [2*NUM_REQ-1:0] double_req = {request,request};
    wire [2*NUM_REQ-1:0] double_gnt = double_req & ~(double_req - {{NUM_REQ{1'b0}}, base});
    wire [NUM_REQ-1:0] grant_full;
    assign grant_full = double_gnt[NUM_REQ-1:0] | double_gnt[2*NUM_REQ-1:NUM_REQ];
    assign grant = (!arb_enable) ? ((|(single_mask & request)) ? single_mask : {NUM_REQ{1'b0}}) : grant_full;

endmodule

