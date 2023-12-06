module timeMeasure(
    input               clk,
    input               rst_n,

    input               send_done,
    input               recv_done,

    output [31:0]       us_tick_num
);

    reg [31:0] data_cnt;
    reg [31:0] us_tick;
    reg [31:0] us_tick_num_reg;
    always@(posedge clk) begin
        if(~rst_n) begin
            data_cnt    <= 32'd0;
        end else if(send_done || data_cnt == 32'd124) begin
            data_cnt    <= 32'd0;
        end else begin
            data_cnt    <= data_cnt + 1'b1;
        end
    end

    always@(posedge clk) begin
        if(~rst_n) begin
            us_tick    <= 32'd0;
        end else if(send_done) begin
            us_tick    <= 32'd0;
        end else if(data_cnt == 32'd124) begin
            us_tick    <= us_tick + 1'b1;
        end
    end

    always@(posedge clk) begin
        if(~rst_n) begin
            us_tick_num_reg    <= 32'd0;
        end else if(send_done) begin
            us_tick_num_reg    <= 32'd0;
        end else if(recv_done) begin
            us_tick_num_reg    <= us_tick + 1'b1;
        end
    end

    assign us_tick_num = us_tick_num_reg;

endmodule
