`timescale 1ns / 1ps
module axis_fork #(
    parameter DATA_WD = 64
)(
    input                       clk,
    input                       rst,

    input                       fork_enable,

    input                       s_axis_tvalid,
    input  [DATA_WD-1 : 0]      s_axis_tdata,
    output                      s_axis_tready,

    output                      m00_axis_tvalid,
    output [DATA_WD-1 : 0]      m00_axis_tdata,
    input                       m00_axis_tready,

    output                      m01_axis_tvalid,
    output [DATA_WD-1 : 0]      m01_axis_tdata,
    input                       m01_axis_tready
);

    reg [DATA_WD-1 : 0] data_reg;
    reg valid_reg;

    reg fork_flag;
    always @(posedge clk) begin
        if(rst) begin
            fork_flag <= 1'b0;
        end else if(s_axis_tready && s_axis_tvalid && fork_enable) begin
            fork_flag <= !fork_flag;
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            valid_reg <= 1'b0;
            data_reg  <=  'b0;
        end else if(s_axis_tready) begin
            valid_reg <= s_axis_tvalid;
            data_reg  <= s_axis_tdata;
        end
    end

    assign s_axis_tready   = !valid_reg | ((m00_axis_tready && m00_axis_tvalid) | (m01_axis_tready && m01_axis_tvalid));

    assign m00_axis_tdata  = data_reg;
    assign m00_axis_tvalid =  fork_flag ? valid_reg : 1'b0;

    assign m01_axis_tdata  = data_reg;
    assign m01_axis_tvalid = !fork_flag ? valid_reg : 1'b0;

endmodule
