`timescale 1ns / 1ps

`define RX_STATE_IDEL       32'd0
`define RX_STATE_RECEVING   32'd1
`define RX_STATE_DONE       32'd2
`define TX_STATE_IDEL       32'd0
`define TX_STATE_SENDING    32'd1
`define TX_STATE_DONE       32'd2

module PAICORE_regfile #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter All_Channel = 4,
    parameter REG_NUM    = 32
)
(
    input  wire                   clk,
    input  wire                   rst,

    input  wire                   i_tx_done  ,  // just use to debug, not to control.
    input  wire                   i_rx_done  ,	// to reg0, update rxstate to done.
    output wire                   o_rx_rcving,  // from reg0, inform rxstate is recving.

    input                         cpu2fifo_plus ,
    input                         fifo2snn_plus ,
    input                         snn2fifo_plus ,
    input                         fifo2cpu_plus ,
    input  [63:0]                 write_data,
    input  [63:0]                 read_data,
    input  [31:0]                 data_cnt,
    input  [31:0]                 tlast_cnt,

    output [31:0]                 send_len,
    output [31:0]                 oFrameNumMax,
    output  [2:0]                 PAICORE_CTRL,
    output                        DataPath_Reset_n,
    output                        single_channel,
    output [All_Channel-1:0]      single_channel_mask, 
    output [All_Channel-1:0]      oen,

    input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    input  wire [2:0]             s_axil_awprot,
    input  wire                   s_axil_awvalid,
    output wire                   s_axil_awready,

    input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    input  wire                   s_axil_wvalid,
    output wire                   s_axil_wready,

    output wire [1:0]             s_axil_bresp,
    output wire                   s_axil_bvalid,
    input  wire                   s_axil_bready,

    input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    input  wire [2:0]             s_axil_arprot,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    
    output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    output wire [1:0]             s_axil_rresp,
    output wire                   s_axil_rvalid,
    input  wire                   s_axil_rready

);
    reg  [DATA_WIDTH-1:0]	user_reg [REG_NUM-1:0];
    wire [REG_NUM-1:0]      user_write;
    wire [DATA_WIDTH-1:0]   user_wdata [REG_NUM-1:0];

    reg  rx_done_delay, tx_done_delay;
    wire rx_done_pulse, tx_done_pulse; 
    wire [DATA_WIDTH-1:0] rx_state, tx_state;

    always @(posedge clk) begin
        rx_done_delay <= i_rx_done;
        tx_done_delay <= i_tx_done;
    end

    assign rx_done_pulse = i_rx_done & ~rx_done_delay;
    assign tx_done_pulse = i_tx_done & ~tx_done_delay;

    // rx_state
    assign user_write[0] = rx_done_pulse;
    assign user_wdata[0] = `RX_STATE_DONE;
    // tx_state
    assign user_write[1] = tx_done_pulse;
    assign user_wdata[1] = `TX_STATE_DONE;
    // cpu2fifo_cnt
    assign user_write[2] = cpu2fifo_plus;
    assign user_wdata[2] = user_reg[2] + 1;
    // fifo2snn_cnt
    assign user_write[3] = fifo2snn_plus;
    assign user_wdata[3] = user_reg[3] + 1;
    // cpu2fifo_cnt
    assign user_write[4] = snn2fifo_plus;
    assign user_wdata[4] = user_reg[4] + 1;
    // fifo2snn_cnt
    assign user_write[5] = fifo2cpu_plus;
    assign user_wdata[5] = user_reg[5] + 1;
    // write_data 
    assign user_write[6] = cpu2fifo_plus;
    assign user_write[7] = cpu2fifo_plus;
    assign user_wdata[6] = write_data[31:0];
    assign user_wdata[7] = write_data[63:32];
    // read_data 
    assign user_write[8] = fifo2cpu_plus;
    assign user_write[9] = fifo2cpu_plus;
    assign user_wdata[8] = read_data[31:0];
    assign user_wdata[9] = read_data[63:32];
    // data_cnt 
    assign user_write[10] = 1'b1;
    assign user_wdata[10] = data_cnt;
    // tlast_cnt 
    assign user_write[11] = 1'b1;
    assign user_wdata[11] = tlast_cnt;


    assign rx_state     = user_reg[0];
    assign tx_state     = user_reg[1];
    assign o_rx_rcving = (rx_state == `RX_STATE_RECEVING); // config by PS, to avoid interference caused by done signals during startup

    assign send_len             = user_reg[20];
    assign PAICORE_CTRL         = user_reg[21][2:0];
    assign oFrameNumMax         = user_reg[22];
    assign DataPath_Reset_n     = user_reg[23][0];
    assign single_channel       = user_reg[24][0];
    assign single_channel_mask  = user_reg[25][All_Channel-1:0];
    assign oen                  = user_reg[26][All_Channel-1:0];

    genvar j;
    generate
        for( j = 12 ; j <= REG_NUM-1; j = j+1) begin
            assign user_write[j] = 1'b0;
            assign user_wdata[j] = {DATA_WIDTH{1'b0}};
        end
    endgenerate

    reg [ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg                     axi_awready;
    reg                     axi_wready;
    reg [1 : 0]             axi_bresp;
    reg                     axi_bvalid;
    reg [ADDR_WIDTH-1 : 0]  axi_araddr;
    reg                     axi_arready;
    reg [DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]             axi_rresp;
    reg                     axi_rvalid;

    localparam integer ADDR_LSB = (DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = $clog2(REG_NUM) - 1;

    wire                    slv_reg_rden, slv_reg_wren;
    integer                 byte_index;
    reg                     aw_en;

    // I/O Connections assignments

    assign s_axil_awready   = axi_awready;
    assign s_axil_wready    = axi_wready;
    assign s_axil_bresp	    = axi_bresp;
    assign s_axil_bvalid    = axi_bvalid;
    assign s_axil_arready   = axi_arready;
    assign s_axil_rdata     = axi_rdata;
    assign s_axil_rresp     = axi_rresp;
    assign s_axil_rvalid    = axi_rvalid;

    always @( posedge clk) begin
        if (rst) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end
        else begin 
            if (~axi_awready && s_axil_awvalid && s_axil_wvalid && aw_en) begin
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end
            else if (s_axil_bready && axi_bvalid) begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    always @( posedge clk ) begin
        if (rst) begin
            axi_awaddr <= 0;
        end else if (~axi_awready && s_axil_awvalid && s_axil_wvalid && aw_en) begin
            axi_awaddr <= s_axil_awaddr;
        end
    end

    always @( posedge clk ) begin
        if (rst) begin
            axi_wready <= 1'b0;
        end 
        else begin    
            if (~axi_wready && s_axil_wvalid && s_axil_awvalid && aw_en )
                axi_wready <= 1'b1;
            else
                axi_wready <= 1'b0;
        end 
    end       

    assign slv_reg_wren = axi_wready && s_axil_wvalid && axi_awready && s_axil_awvalid;

    wire [REG_NUM-1:0] axi_reg_sel, slv_reg_wren_vec;
    assign axi_reg_sel = ({REG_NUM{1'b0}} + 1) << (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]);
    assign slv_reg_wren_vec = axi_reg_sel & {REG_NUM{slv_reg_wren}};

    // support strb
    // genvar i;
    // generate
    //     for( i = 0 ; i <= REG_NUM-1; i = i+1) begin
    //         always @( posedge clk )begin
    //             if (rst) begin
    //                 user_reg[i] <= 0;
    //             end else if (slv_reg_wren_vec[i])begin
    //                 for ( byte_index = 0; byte_index <= (DATA_WIDTH/8)-1; byte_index = byte_index+1 )
    //                     if ( s_axil_wstrb[byte_index] == 1 ) begin
    //                         user_reg[i][(byte_index*8) +: 8] <= s_axil_wdata[(byte_index*8) +: 8];
    //                     end
    //             end
    //         end
    //     end
    // endgenerate

    // not support strb

    genvar i;
    generate
        for( i = 0 ; i <= REG_NUM-1; i = i+1) begin
            always @( posedge clk )begin
                if (rst) begin
                    user_reg[i] <= 0;
                end else if (user_write[i]) begin
                    user_reg[i] <= user_wdata[i];
                end else if (slv_reg_wren_vec[i]) begin
                    user_reg[i] <= s_axil_wdata;
                end
            end
        end
    endgenerate

    always @( posedge clk ) begin
        if ( rst ) begin
            axi_bvalid  <= 0;
            axi_bresp   <= 2'b0;
        end 
        else begin
            if (axi_awready && s_axil_awvalid && ~axi_bvalid && axi_wready && s_axil_wvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;
            end else if (s_axil_bready && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
        end  
    end   

    always @( posedge clk ) begin
        if ( rst ) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin    
            if (~axi_arready && s_axil_arvalid && (~s_axil_rvalid || (s_axil_rvalid && s_axil_rready))) begin
                axi_arready <= 1'b1;
                axi_araddr  <= s_axil_araddr;
            end else begin
                axi_arready <= 1'b0;
            end
        end 
    end
 
    always @( posedge clk) begin
        if ( rst ) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin
            if (axi_arready && s_axil_arvalid && ~axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;
            end   
            else if (axi_rvalid && s_axil_rready) begin
                axi_rvalid <= 1'b0;
            end
        end
    end    

    assign slv_reg_rden = axi_arready & s_axil_arvalid & ~axi_rvalid;

    wire [DATA_WIDTH-1:0]    reg_data_out;
    assign reg_data_out = user_reg[axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]];

    always @( posedge clk) begin
        if ( rst ) begin
            axi_rdata  <= 0;
        end else if (slv_reg_rden) begin
            axi_rdata <= reg_data_out;
        end
    end

endmodule
