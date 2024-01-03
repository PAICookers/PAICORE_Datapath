`timescale 1ns / 1ps
module transport_up(
    input                       s_axis_aclk,
    input                       s_axis_aresetn,

    // PAICore Signals:
    output                      s_axis_tready,
    input                       s_axis_tvalid,
    input           [63: 0]     s_axis_tdata  ,
    
    input                       i_recv_done  ,
    input                       i_recv_busy  ,

    //axi stream fifo signals:
    input                       m_axis_tready ,
    output          [63: 0]     m_axis_tdata  ,
    output                      m_axis_tvalid ,
    output                      m_axis_tlast ,

    output                      m_axis_hsked,

    //control signal:
    input                       i_rx_rcving  ,
    output                      o_rx_done
);

    assign m_axis_hsked  = m_axis_tready && m_axis_tvalid;

    // 1. get real done: 
    reg     [31: 0]     done_count;
    reg                 real_done, real_done_delay;
    wire                real_done_pos;
    localparam DONE_COUNTER = 1024;
    always @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
        if (~s_axis_aresetn) begin
            done_count  <= 'b0;
        end else if (i_rx_rcving && i_recv_done && !i_recv_busy) begin        
            if (done_count >= DONE_COUNTER)
                done_count  <= done_count;
            else
                done_count  <= done_count + 1;
        end else begin
            done_count  <= 'b0;
        end
    end

    always @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
        if(~s_axis_aresetn) begin
            real_done   <= 1'b0;
        end else if(done_count >= DONE_COUNTER) begin
            real_done   <= 1'b1;
        end else begin
            real_done   <= 1'b0;
        end
    end

    always @(posedge s_axis_aclk) begin
        real_done_delay <= real_done;
    end

    assign real_done_pos = real_done & (~real_done_delay);

    // 2. transport:
    assign m_axis_tvalid = s_axis_tvalid | real_done_pos;
    assign m_axis_tlast  = real_done_pos;
    assign m_axis_tdata  = real_done_pos ? 64'hffff_ffff_ffff_ffff : s_axis_tdata;
    assign s_axis_tready = m_axis_tready;

    assign o_rx_done = real_done_pos;

endmodule
