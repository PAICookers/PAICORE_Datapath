`timescale 1ns / 1ps
module PAICORE_send_2C(
    input               s_axis_aclk,
    input               s_axis_aresetn,

    input               fork_enable,
    input      [31:0]   send_len,
    output     [31:0]   data_cnt,
    output     [31:0]   tlast_cnt,

    output              write_hsked,
    output     [63:0]   write_data,
    output              snn_in_hsked,

    output              s_axis_tready,
    input      [63:0]   s_axis_tdata,
    input               s_axis_tlast,
    input               s_axis_tvalid,

    input               acknowledge_C0,
    output     [31:0]   dout_C0,
    output              request_C0,

    input               acknowledge_C1,
    output     [31:0]   dout_C1,
    output              request_C1,

    output              o_tx_done
);

    wire                gen_last_tready;
    wire     [63:0]     gen_last_tdata ;
    wire                gen_last_tlast ;
    wire                gen_last_tvalid;

    wire                fifo_tready;
    wire     [63:0]     fifo_tdata ;
    wire                fifo_tlast ;
    wire                fifo_tvalid;

    wire                fork_C0_tready;
    wire     [63:0]     fork_C0_tdata ;
    wire                fork_C0_tvalid;

    wire                fork_C1_tready;
    wire     [63:0]     fork_C1_tdata ;
    wire                fork_C1_tvalid;

    wire                sender_available;
    wire                sender_valid;
    wire     [63:0]     sender_data;

    wire                o_tx_done_C0;
    wire                o_tx_done_C1;
    reg      [1:0]      o_tx_done_reg;

    always @(posedge s_axis_aclk) begin
        if(!s_axis_aresetn) begin
            o_tx_done_reg <= 2'b0;
        end else if(o_tx_done) begin
            o_tx_done_reg <= 2'b0;
        end else if(o_tx_done_C0 && o_tx_done_C1) begin
            o_tx_done_reg <= 2'b10;        
        end else if(o_tx_done_C0) begin
            o_tx_done_reg <= o_tx_done_reg + 1'b1;
        end else if(o_tx_done_C1) begin
            o_tx_done_reg <= o_tx_done_reg + 1'b1;
        end
    end

    assign o_tx_done = (o_tx_done_reg == 2'b10);

    axis_fifo_top u_axis_fifo_top(
        .s_axis_aclk     (s_axis_aclk       ),
        .s_axis_aresetn  (s_axis_aresetn    ),
        .s_axis_tready   (s_axis_tready     ),
        .s_axis_tdata    (s_axis_tdata      ),
        .s_axis_tlast    (s_axis_tlast      ),
        .s_axis_tvalid   (s_axis_tvalid     ),
        .m_axis_tready   (fifo_tready       ),
        .m_axis_tdata    (fifo_tdata        ),
        .m_axis_tlast    (fifo_tlast        ),
        .m_axis_tvalid   (fifo_tvalid       )  
    );

    axis_fork #(
        .DATA_WD            (64             )
    ) u_axis_fork(
        .clk                (s_axis_aclk    ),
        .rst                (!s_axis_aresetn),
        .fork_enable        (fork_enable    ),
        .s_axis_tvalid      (fifo_tvalid    ),
        .s_axis_tdata       (fifo_tdata     ),
        .s_axis_tready      (fifo_tready    ),
        .m00_axis_tvalid    (fork_C0_tvalid ),
        .m00_axis_tdata     (fork_C0_tdata  ),
        .m00_axis_tready    (fork_C0_tready ),
        .m01_axis_tvalid    (fork_C1_tvalid ),
        .m01_axis_tdata     (fork_C1_tdata  ),
        .m01_axis_tready    (fork_C1_tready )
    );

    fork_send u_fork_send_C0(
        .s_axis_aclk        (s_axis_aclk    ),
        .s_axis_aresetn     (s_axis_aresetn ),
        .send_len           (send_len >> 1  ),
        .data_cnt           (data_cnt       ),
        .tlast_cnt          (tlast_cnt      ),
        .write_hsked        (write_hsked    ),
        .write_data         (write_data     ),
        .snn_in_hsked       (snn_in_hsked   ),
        .s_axis_tready      (fork_C0_tready ),
        .s_axis_tdata       (fork_C0_tdata  ),
        .s_axis_tlast       (fork_C0_tvalid ),
        .s_axis_tvalid      (fork_C0_tvalid ),
        .acknowledge        (acknowledge_C0 ),
        .dout               (dout_C0        ),
        .request            (request_C0     ),
        .o_tx_done          (o_tx_done_C0   )
    );

    fork_send u_fork_send_C1(
        .s_axis_aclk        (s_axis_aclk    ),
        .s_axis_aresetn     (s_axis_aresetn ),
        .send_len           (send_len >> 1  ),
        .data_cnt           (               ),
        .tlast_cnt          (               ),
        .write_hsked        (               ),
        .write_data         (               ),
        .snn_in_hsked       (               ),
        .s_axis_tready      (fork_C1_tready ),
        .s_axis_tdata       (fork_C1_tdata  ),
        .s_axis_tlast       (fork_C1_tvalid ),
        .s_axis_tvalid      (fork_C1_tvalid ),
        .acknowledge        (acknowledge_C1 ),
        .dout               (dout_C1        ),
        .request            (request_C1     ),
        .o_tx_done          (o_tx_done_C1   )
    );

endmodule
