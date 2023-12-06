module axis_gen_last(
    input               s_axis_aclk,
    input               s_axis_aresetn,

    input      [31:0]   send_len,
    output reg [31:0]   data_cnt,
    output     [31:0]   tlast_cnt,

    output              s_axis_tready,
    input      [63:0]   s_axis_tdata,
    input               s_axis_tlast,
    input               s_axis_tvalid,

    input               m_axis_tready,
    output     [63:0]   m_axis_tdata,
    output              m_axis_tlast,
    output              m_axis_tvalid,

    output              s_axis_hsked,
    output     [63:0]   write_data
);

    assign s_axis_tready = m_axis_tready;
    assign s_axis_hsked  = s_axis_tready&&s_axis_tvalid;
    assign write_data = s_axis_tdata;

    always@(posedge s_axis_aclk) begin
        if(~s_axis_aresetn) begin
            data_cnt <= 32'd1;
        end else if(m_axis_tlast) begin
            data_cnt <= 32'd1;
        end else if(s_axis_hsked) begin
            data_cnt <= data_cnt + 1'b1;
        end
    end

    reg [15:0] tlast_in_cnt;
    always@(posedge s_axis_aclk) begin
        if(~s_axis_aresetn) begin
            tlast_in_cnt <= 16'd0;
        end else if(s_axis_hsked && s_axis_tlast) begin
            tlast_in_cnt <= tlast_in_cnt + 1'b1;
        end
    end
    
    reg [15:0] tlast_out_cnt;
    always@(posedge s_axis_aclk) begin
        if(~s_axis_aresetn) begin
            tlast_out_cnt <= 16'd0;
        end else if(m_axis_tlast && s_axis_hsked) begin
            tlast_out_cnt <= tlast_out_cnt + 1'b1;
        end
    end
    assign tlast_cnt = {tlast_out_cnt,tlast_in_cnt};
    assign m_axis_tlast = ((data_cnt == send_len) && s_axis_hsked);
    assign m_axis_tdata = s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid;

endmodule