`timescale 1ns / 1ps
module axis_join #(
    parameter DATA_WD = 64
)(
    input                       clk,
    input                       rst,

    input                       s00_axis_tvalid,
    input  [DATA_WD-1 : 0]      s00_axis_tdata,
    output                      s00_axis_tready,

    input                       s01_axis_tvalid,
    input  [DATA_WD-1 : 0]      s01_axis_tdata,
    output                      s01_axis_tready,

    output                      m_axis_tvalid,
    output [DATA_WD-1 : 0]      m_axis_tdata,
    input                       m_axis_tready
);

    reg [DATA_WD-1 : 0] C0_data_reg;
    reg [DATA_WD-1 : 0] C1_data_reg;
    reg C0_valid_reg;
    reg C1_valid_reg;

    always @(posedge clk) begin
        if(rst) begin
            C0_valid_reg <= 1'b0;
            C0_data_reg  <=  'b0;
        end else if(s00_axis_tready) begin
            C0_valid_reg <= s00_axis_tvalid;
            C0_data_reg  <= s00_axis_tdata;
        end
    end
    always @(posedge clk) begin
        if(rst) begin
            C1_valid_reg <= 1'b0;
            C1_data_reg  <=  'b0;
        end else if(s01_axis_tready) begin
            C1_valid_reg <= s01_axis_tvalid;
            C1_data_reg  <= s01_axis_tdata;
        end
    end

    assign s00_axis_tready  = !C0_valid_reg | (m_axis_tready);
    assign s01_axis_tready  = (!C1_valid_reg | (m_axis_tready)) && !s00_axis_tvalid;

    assign m_axis_tdata  = C0_valid_reg ? C0_data_reg  : C1_data_reg;
    assign m_axis_tvalid = C0_valid_reg ? C0_valid_reg : C1_valid_reg;

endmodule
