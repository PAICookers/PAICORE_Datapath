`timescale 1ns / 1ps
module axis_dropData #
(
    parameter DATA_WIDTH  = 64
)
(
    input                   clk             ,
    input                   rst             ,

    output                  s_axis_tready   ,
    input  [DATA_WIDTH-1:0] s_axis_tdata    ,
    input                   s_axis_tlast    ,
    input                   s_axis_tvalid   ,

    input                   m_axis_tready   ,
    output [DATA_WIDTH-1:0] m_axis_tdata    ,
    output                  m_axis_tlast    ,
    output                  m_axis_tvalid   
);

    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid && !s_axis_tlast;
    assign m_axis_tlast  = s_axis_tlast;

endmodule