`timescale 1ns / 1ps
module transport_up(
    input                       s_axis_aclk,
    input                       s_axis_aresetn,

    // PAICore Signals:
    output                      o_recv_available,
    input                       i_recv_valid,
    input           [63: 0]     i_recv_tdata  ,
    
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
    reg     [5: 0]      done_count;
    reg                 real_done, real_done_delay;
    wire                real_done_pluse;

    always @(posedge s_axis_aclk or negedge s_axis_aresetn) begin
        if(~s_axis_aresetn) begin
            done_count  <= 6'b0;
            real_done   <= 1'b0;
        end else if(i_recv_done && !i_recv_busy) begin                   
            if(~&done_count) begin         // only judge 16 cycles, hold on 15 when exceed
                done_count  <= done_count + 1;
                if(done_count >= 60)
                    real_done   <= 1'b1;
                else
                    real_done   <= 1'b0;
            end
        end else begin
            done_count  <= 6'b0;
            real_done   <= 1'b0;
        end
    end

    always @(posedge s_axis_aclk) begin
        real_done_delay <= real_done;
    end

    assign real_done_pluse = real_done & (~real_done_delay);

    // 2. transport:
    assign m_axis_tvalid = i_rx_rcving & (i_recv_valid | real_done_pluse);
    assign m_axis_tlast = real_done_pluse;
    assign m_axis_tdata = real_done_pluse ? 64'hffff_ffff_ffff_ffff : i_recv_tdata;
    assign o_recv_available = i_rx_rcving & m_axis_tready;

    assign o_rx_done = real_done_pluse;

endmodule
