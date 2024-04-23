`timescale 1ns / 1ps
module Round_Robin_arbiter_base#(
    parameter NUM_REQ = 4
)(
    input                   clk,
    input                   rst_n,
    input                   arb_enable,
    input  [NUM_REQ-1:0]    single_mask,
    input  [NUM_REQ-1:0]    request,
    output [NUM_REQ-1:0]    grant
);

    reg [NUM_REQ-1:0]   hist_req;

    always @(posedge clk) begin
        if(!rst_n) begin
            hist_req <= {{NUM_REQ-1{1'b0}}, 1'b1};
        end else if(|request) begin
            hist_req <= {grant[NUM_REQ-2:0], grant[NUM_REQ-1]};
        end
    end

    Fixed_arbiter_base #(
        .NUM_REQ    (NUM_REQ    )
    ) u_Fixed_arbiter_base(
        .arb_enable (arb_enable ),
        .single_mask(single_mask),
        .base       (hist_req   ),
        .request    (request    ),
        .grant      (grant      )
    );

endmodule