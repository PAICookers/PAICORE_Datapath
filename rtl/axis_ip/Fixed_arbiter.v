
// // no parameterization
// module Fixed_arbiter#(
//     parameter NUM_REQ = 4
// )(
//     input                   arb_enable,
//     input  [NUM_REQ-1:0]    request,
//     output [NUM_REQ-1:0]    grant
// );
//     reg [NUM_REQ-1:0] grant_reg;
//     always@(*)begin
//         case(1'b1)
//             request[3] : grant_reg = 4'b1000;
//             request[2] : grant_reg = 4'b0100;
//             request[1] : grant_reg = 4'b0010;
//             request[0] : grant_reg = 4'b0001;
//             default: grant_reg = 4'b0000;
//         endcase
//     end

//     assign grant = arb_enable ? grant_reg : 4'b0001;

// endmodule

// parameterization
module Fixed_arbiter#(
    parameter NUM_REQ = 4
)(
    input                   arb_enable,
    input  [NUM_REQ-1:0]    request,
    output [NUM_REQ-1:0]    grant,
    output [NUM_REQ-1:0]    pre_req
);
    wire [NUM_REQ-1:0] grant_full;
    // // method 1

    // pre_req is used to store the previous requests.
    assign pre_req[0] = 0;
    // for(genvar i=1; i<NUM_REQ ; i=i+1)begin
    //     assign pre_req[i] = request[i-1] | pre_req[i-1]; // or all higher priority requests
    // end

    assign pre_req[NUM_REQ-1:1] = request[NUM_REQ-2:0] | pre_req[NUM_REQ-2:0];

    // arb_enable is used to enable the arbiter
    // when arb_enable is 0, the arbiter only grant the highest priority request
    assign grant_full = request & ~pre_req; // current i_req & no higher priority request

    // method 2

    // // request bitwise and its 2's complement, can get the lowest request bit.
    // assign grant_full = request & (~(request-1));

    assign grant = (!arb_enable) ? (request[0] ? {NUM_REQ{1'b0}} + 1'b1 : {NUM_REQ{1'b0}}) : grant_full;

endmodule

// input base priority
module Fixed_arbiter_base#(
    parameter NUM_REQ = 4
)(
    input                   arb_enable,
    input  [NUM_REQ-1:0]    base,
    input  [NUM_REQ-1:0]    request,
    output [NUM_REQ-1:0]    grant
);
    
    wire [2*NUM_REQ-1:0] double_req = {request,request};
    wire [2*NUM_REQ-1:0] double_gnt = double_req & ~(double_req - base);
    wire [NUM_REQ-1:0] grant_full;
    assign grant_full = double_gnt[NUM_REQ-1:0] | double_gnt[2*NUM_REQ-1:NUM_REQ];
    assign grant = (!arb_enable) ? (request[0] ? {NUM_REQ{1'b0}} + 1'b1 : {NUM_REQ{1'b0}}) : grant_full;

endmodule

