`timescale 1ns / 1ps
module axis_dataPadding(
    input               s_axis_aclk,
    input               s_axis_aresetn,

    input [31:0]        oFrameNumMax,

    output              s_axis_tready,
    input [63:0]        s_axis_tdata,
    input               s_axis_tlast,
    input               s_axis_tvalid,

    input               m_axis_tready,
    output [63:0]       m_axis_tdata,
    output              m_axis_tlast,
    output              m_axis_tvalid,

    output              m_axis_hsked,
    output [63:0]       read_data
);
    // make output frame num known
    assign read_data = m_axis_tdata;
    
    wire s_axis_hsked;
    reg extraFrameFlag;
    
    reg [31:0] data_cnt;
    always@(posedge s_axis_aclk) begin
        if(~s_axis_aresetn) begin
            data_cnt <= 32'd1;
        end else if(m_axis_hsked && m_axis_tlast) begin
            data_cnt <= 32'd1;
        end else if(m_axis_hsked) begin
            data_cnt <= data_cnt + 1'b1;
        end
    end

    always@(posedge s_axis_aclk) begin
        if(~s_axis_aresetn) begin
            extraFrameFlag <= 1'b0;
        end else if(s_axis_hsked && s_axis_tlast && (data_cnt < oFrameNumMax)) begin
            extraFrameFlag <= 1'b1;
        end else if(m_axis_hsked && m_axis_tlast) begin
            extraFrameFlag <= 1'b0;
        end
    end
       
    assign s_axis_tready = m_axis_tready && !extraFrameFlag;
    
    assign s_axis_hsked  = s_axis_tready&&s_axis_tvalid;
    assign m_axis_hsked  = m_axis_tready&&m_axis_tvalid;

    assign m_axis_tdata  = extraFrameFlag ? 64'h0000_0000_0000_0000 : s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid || extraFrameFlag;
    assign m_axis_tlast  = (s_axis_tlast && (data_cnt >= oFrameNumMax)) || (extraFrameFlag && data_cnt == oFrameNumMax);

endmodule
