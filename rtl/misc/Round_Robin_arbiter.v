`timescale 1ns / 1ps
module Round_Robin_arbiter#(
    parameter NUM_REQ = 4
)(
    input                   clk,
    input                   rst_n,
    input                   arb_enable,
    input  [NUM_REQ-1:0]    single_mask,
    input  [NUM_REQ-1:0]    request,
    output [NUM_REQ-1:0]    grant
);

    wire [NUM_REQ-1:0] req_masked;
    wire [NUM_REQ-1:0] mask_higher_pri_reqs;
    wire [NUM_REQ-1:0] grant_masked;

    wire [NUM_REQ-1:0] unmask_higher_pri_reqs;
    wire [NUM_REQ-1:0] grant_unmasked;

    wire no_req_masked;
    reg  [NUM_REQ-1:0] mask_reg;
    wire [NUM_REQ-1:0] grant_full;

    // Simple priority arbitration for masked portion
    assign req_masked = request & mask_reg;
    Fixed_arbiter #(
        .NUM_REQ    (NUM_REQ)
    ) u_grant_masked(
        .arb_enable (1'b1                   ),
        .single_mask({NUM_REQ{1'b0}}        ),
        .request    (req_masked             ),
        .grant      (grant_masked           ),
        .pre_req    (mask_higher_pri_reqs   )
    );

    // Simple priority arbitration for unmasked portion
    Fixed_arbiter #(
        .NUM_REQ    (NUM_REQ)
    ) u_grant_unmasked(
        .arb_enable (1'b1                   ),
        .single_mask({NUM_REQ{1'b0}}        ),
        .request    (request                ),
        .grant      (grant_unmasked         ),
        .pre_req    (unmask_higher_pri_reqs )
    );

    // Use grant_masked if there is any there, otherwise use grant_unmasked. 
    assign no_req_masked = ~(|req_masked);
    assign grant_full = grant_masked | ({NUM_REQ{no_req_masked}} & grant_unmasked);

    // Pointer update
    always @ (posedge clk) begin
        if (!rst_n) begin
            mask_reg <= {NUM_REQ{1'b1}};
        end else begin
            if (|req_masked) begin // Which arbiter was used?
                mask_reg <= mask_higher_pri_reqs;
            end else if (|request) begin // Only update if there's a req when already mask all
                mask_reg <= unmask_higher_pri_reqs;
            end
        end
    end

    assign grant = (!arb_enable) ? ((|(single_mask & request)) ? single_mask : {NUM_REQ{1'b0}}) : grant_full;

endmodule
