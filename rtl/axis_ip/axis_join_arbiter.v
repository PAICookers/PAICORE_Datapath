`timescale 1ns / 1ps
module axis_join_arbiter #(
    parameter S_COUNT = 4,
    parameter DATA_WIDTH = 64
)(
    input                                   clk,
    input                                   rst,

    input  wire [S_COUNT-1:0]               s_axis_tvalid,
    input  wire [S_COUNT*DATA_WIDTH-1:0]    s_axis_tdata ,
    input  wire [S_COUNT-1:0]               s_axis_tlast ,
    output wire [S_COUNT-1:0]               s_axis_tready,

    output wire                             m_axis_tvalid,
    output wire [DATA_WIDTH-1:0]            m_axis_tdata ,
    output wire                             m_axis_tlast ,
    input  wire                             m_axis_tready
);

    reg [S_COUNT-1:0] tlast_flag;

    always @(posedge clk) begin
        if(rst) begin
            tlast_flag <= {S_COUNT{1'b0}};
        end else if(m_axis_tready && m_axis_tvalid && m_axis_tlast) begin
            tlast_flag <= {S_COUNT{1'b0}};
        end else if(m_axis_tvalid) begin
            tlast_flag <= tlast_flag | (s_axis_tlast & (s_axis_tvalid & s_axis_tready));
        end
    end

    wire [S_COUNT-1:0] grant_out;
    parameter Use_Fixed = 0;
    generate
        if (S_COUNT == 1) begin
            assign grant_out = 1'b1;
        end else if (Use_Fixed) begin
            Fixed_arbiter #(
                .NUM_REQ    (S_COUNT                                    )
            ) u_Fixed_arbiter(
                .arb_enable (1'b1                                       ),
                .single_mask({S_COUNT{1'b0}}                            ),
                .request    (s_axis_tvalid & {S_COUNT{m_axis_tready}}   ),
                .grant      (s_axis_tready                              ),
                .pre_req    (                                           )
            );
        end else begin
            Round_Robin_arbiter #(
                .NUM_REQ    (S_COUNT                                    )
            ) u_Round_Robin_arbiter(
                .clk        (clk                                        ),
                .rst_n      (!rst                                       ),
                .arb_enable (1'b1                                       ),
                .single_mask({S_COUNT{1'b0}}                            ),
                .request    (s_axis_tvalid & {S_COUNT{m_axis_tready}}   ),
                .grant      (s_axis_tready                              )
            );
        end
    endgenerate

    integer idx;
    reg [S_COUNT*DATA_WIDTH-1:0]    data_shift;
    reg [S_COUNT-1:0]               gnt_shift;
    always @(*) begin
        data_shift = s_axis_tdata;  
        gnt_shift  = s_axis_tready;  
        for( idx = 0; idx < S_COUNT - 1; idx = idx + 1) begin
            if(!gnt_shift[0]) begin
                data_shift = data_shift >> DATA_WIDTH;
                gnt_shift  = gnt_shift  >> 1;
            end
        end
    end

    assign m_axis_tdata  = data_shift[DATA_WIDTH-1:0];
    assign m_axis_tvalid = |(s_axis_tvalid & s_axis_tready);
    assign m_axis_tlast  = &(tlast_flag | (s_axis_tlast & (s_axis_tvalid & s_axis_tready))); // bad timing, sim only

endmodule
