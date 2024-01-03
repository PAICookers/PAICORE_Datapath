`resetall
`timescale 1ns / 1ps
`default_nettype none

module axil_regfile #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter REG_NUM    = 32
)
(
    input  wire                             clk,
    input  wire                             rst,

    input  wire [REG_NUM-1:0]               user_write,
    input  wire [DATA_WIDTH*REG_NUM-1:0]    user_wdata,
    output wire [DATA_WIDTH*REG_NUM-1:0]    user_rdata,

    input  wire [ADDR_WIDTH-1:0]            s_axil_awaddr,
    input  wire [2:0]                       s_axil_awprot,
    input  wire                             s_axil_awvalid,
    output wire                             s_axil_awready,

    input  wire [DATA_WIDTH-1:0]            s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]            s_axil_wstrb,
    input  wire                             s_axil_wvalid,
    output wire                             s_axil_wready,

    output wire [1:0]                       s_axil_bresp,
    output wire                             s_axil_bvalid,
    input  wire                             s_axil_bready,

    input  wire [ADDR_WIDTH-1:0]            s_axil_araddr,
    input  wire [2:0]                       s_axil_arprot,
    input  wire                             s_axil_arvalid,
    output wire                             s_axil_arready,
    
    output wire [DATA_WIDTH-1:0]            s_axil_rdata,
    output wire [1:0]                       s_axil_rresp,
    output wire                             s_axil_rvalid,
    input  wire                             s_axil_rready

);

    reg [DATA_WIDTH-1:0]	user_reg [REG_NUM-1:0];

    reg                     arready_reg;

    reg [DATA_WIDTH-1 : 0]  rdata_reg;
    reg [1 : 0]             rresp_reg;
    reg                     rvalid_reg;

    reg                     awready_reg;
    reg                     wready_reg;

    reg [1 : 0]             bresp_reg;
    reg                     bvalid_reg;

    localparam integer ADDR_LSB = (DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = $clog2(REG_NUM) - 1;

    wire                    slv_reg_wren;
    integer                 byte_index;

    // handshake signals
    wire                    valid_read_request;
    wire                    read_response_stall;
    wire                    valid_write_address;
    wire                    valid_write_data;
    wire                    write_response_stall;
    wire [REG_NUM-1:0]      axi_reg_sel, slv_reg_wren_vec;

    reg  [ADDR_WIDTH-1 : 0] pre_raddr;
    reg  [ADDR_WIDTH-1 : 0] pre_waddr;
    reg  [DATA_WIDTH-1 : 0] pre_wdata;
    reg  [STRB_WIDTH-1 : 0] pre_wstrb;
    wire [ADDR_WIDTH-1 : 0] rd_addr;
    wire [ADDR_WIDTH-1 : 0] wr_addr;
    wire [DATA_WIDTH-1 : 0] wr_data;
    wire [STRB_WIDTH-1 : 0] wr_strb;
    
    // write channel
    assign s_axil_awready   = awready_reg;
    assign s_axil_wready    = wready_reg;
    assign s_axil_bresp	    = bresp_reg;
    assign s_axil_bvalid    = bvalid_reg;

	assign	valid_write_address = s_axil_awvalid || !s_axil_awready;
	assign	valid_write_data    = s_axil_wvalid  || !s_axil_wready;
	assign	write_response_stall= s_axil_bvalid  && !s_axil_bvalid;

    always @( posedge clk ) begin
        if (rst) begin
            awready_reg <= 1'b1;
        end else if (write_response_stall) begin
            // The output channel is stalled
            //	If our buffer is full, we need to remain stalled
            //	Likewise if it is empty, and there's a request,
            //	  we'll need to stall.
            awready_reg <= !valid_write_address;
        end else if (valid_write_data) begin
            // The output channel is clear, and write data
            // are available
            awready_reg <= 1'b1;
        end else begin
            // If we were ready before, then remain ready unless an
            // address unaccompanied by data shows up
            awready_reg <= ((awready_reg) && (!s_axil_awvalid));
        end
    end

    always @( posedge clk ) begin
        if (rst) begin
            wready_reg <= 1'b1;
        end else if (write_response_stall) begin
            // The output channel is stalled
            //	We can remain ready until valid
            //	write data shows up
            wready_reg <= !valid_write_data;
        end else if (valid_write_address) begin
            // The output channel is clear, and a write address
            // is available
            wready_reg <= 1'b1;
        end else begin
            // if we were ready before, and there's no new data avaialble
            // to cause us to stall, remain ready
            wready_reg <= (wready_reg) && (!s_axil_wvalid);
        end
    end

    always @( posedge clk ) begin
        if (s_axil_awready) begin
            pre_waddr <= s_axil_awaddr;
        end
    end

	// Buffer the data
	always @( posedge clk ) begin
        if (s_axil_wready) begin
            pre_wdata <= s_axil_wdata;
            pre_wstrb <= s_axil_wstrb;
        end
    end

    assign wr_addr = s_axil_awready ? s_axil_awaddr : pre_waddr;
    assign wr_data = s_axil_wready  ? s_axil_wdata  : pre_wdata;
    assign wr_strb = s_axil_wready  ? s_axil_wstrb  : pre_wstrb;

    assign slv_reg_wren = !write_response_stall && valid_write_address && valid_write_data;
    assign axi_reg_sel = ({REG_NUM{1'b0}} + 1) << (wr_addr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]);
    assign slv_reg_wren_vec = axi_reg_sel & {REG_NUM{slv_reg_wren}};

    // genvar i;
    // generate
    //     for( i = 0 ; i <= REG_NUM-1; i = i+1) begin
    //         always @( posedge clk )begin
    //             if (rst) begin
    //                 user_reg[i] <= 0;
    //             end else if (slv_reg_wren_vec[i])begin
    //                 for ( byte_index = 0; byte_index <= (DATA_WIDTH/8)-1; byte_index = byte_index+1 )
    //                     if ( wr_strb[byte_index] == 1 ) begin
    //                         user_reg[i][(byte_index*8) +: 8] <= wr_data[(byte_index*8) +: 8];
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
                    user_reg[i] <= user_wdata[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
                end else if (slv_reg_wren_vec[i]) begin
                    user_reg[i] <= wr_data;
                end
            end
        end
    endgenerate

    generate
        for( i = 0 ; i <= REG_NUM-1; i = i+1) begin
            assign user_rdata[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] = user_reg[i];
        end
    endgenerate

    always @( posedge clk ) begin
        if ( rst ) begin
            bvalid_reg <= 1'b0;
            bresp_reg  <= 2'b0;
            // The outgoing response channel should indicate a valid write if ...
            // 1. We have a valid address, and
        end else if (valid_write_address && valid_write_data) begin
            // 2. We had valid data
            // It doesn't matter here if we are stalled or not
            // We can keep setting ready as often as we want
            bvalid_reg <= 1'b1;
        end else if (s_axil_bready) begin
            // Otherwise, if BREADY was true, then it was just accepted
            // and can return to idle now
            bvalid_reg <= 1'b0;
        end
    end

    // read channel
    assign s_axil_arready   = arready_reg;
    assign s_axil_rdata     = rdata_reg;
    assign s_axil_rresp     = rresp_reg;
    assign s_axil_rvalid    = rvalid_reg;

    // addr request or buffer not empty
    assign	valid_read_request  = s_axil_arvalid || !s_axil_arready;
    // data rsp and stall
    assign	read_response_stall = s_axil_rvalid  && !s_axil_rready;

    always @( posedge clk ) begin
        if ( rst ) begin
		    arready_reg <= 1'b1;
        end else if (read_response_stall) begin
            // Outgoing channel is stalled
            //    As long as something is already in the buffer,
            //    arready_reg needs to stay low
		    arready_reg <= !valid_read_request;
        end else begin
		    arready_reg <= 1'b1;
        end
    end

    always @( posedge clk ) begin
        if ( rst ) begin
            rvalid_reg <= 1'b0;
        end else if (read_response_stall) begin
            // Need to stay valid as long as the return path is stalled
            rvalid_reg <= 1'b1;
        end else if (valid_read_request) begin
            rvalid_reg <= 1'b1;
        end else
            // Any stall has cleared, so we can always
            // clear the valid signal in this case
            rvalid_reg <= 1'b0;
    end

    always @( posedge clk ) begin
        // if (s_axil_arready && s_axil_arvalid) begin
        if (s_axil_arready) begin
            pre_raddr <= s_axil_araddr;
        end
    end

    assign rd_addr = s_axil_arready ? s_axil_araddr : pre_raddr;

    always @( posedge clk) begin
        if ( rst ) begin
            rdata_reg  <= 1'b0;
            rresp_reg  <= 2'b0;
        end else if (!read_response_stall) begin
            rdata_reg <= user_reg[rd_addr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]];
        end
    end

endmodule


`resetall