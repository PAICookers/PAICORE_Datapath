`resetall
`timescale 1ns / 1ps
`default_nettype none

module axil_regfile_axis_wr #
(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter REG_NUM    = 1024
)
(
    input  wire                     clk,
    input  wire                     rst,

    output wire                     s_axis_tready,
    input  wire[DATA_WIDTH-1:0]     s_axis_tdata,
    input  wire                     s_axis_tlast,
    input  wire                     s_axis_tvalid,

    output reg [31:0]               axis_write_num,

    input  wire [ADDR_WIDTH-1:0]    s_axil_awaddr,
    input  wire [2:0]               s_axil_awprot,
    input  wire                     s_axil_awvalid,
    output wire                     s_axil_awready,

    input  wire [DATA_WIDTH-1:0]    s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axil_wstrb,
    input  wire                     s_axil_wvalid,
    output wire                     s_axil_wready,

    output wire [1:0]               s_axil_bresp,
    output wire                     s_axil_bvalid,
    input  wire                     s_axil_bready,

    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr,
    input  wire [2:0]               s_axil_arprot,
    input  wire                     s_axil_arvalid,
    output wire                     s_axil_arready,

    output wire [DATA_WIDTH-1:0]    s_axil_rdata,
    output wire [1:0]               s_axil_rresp,
    output wire                     s_axil_rvalid,
    input  wire                     s_axil_rready

);

    reg [DATA_WIDTH-1:0]	user_reg [REG_NUM-1:0];

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

    assign slv_reg_wren = s_axis_tready && s_axis_tvalid;
    assign s_axis_tready = 1'b1;
    
    reg [ADDR_WIDTH-1:0] axis_wrAddr;
    wire [REG_NUM-1:0] axi_reg_sel, slv_reg_wren_vec;

    assign axi_reg_sel = ({REG_NUM{1'b0}} + 1) << (axis_wrAddr[OPT_MEM_ADDR_BITS:0]);
    assign slv_reg_wren_vec = axi_reg_sel & {REG_NUM{slv_reg_wren}};

    always@(posedge clk) begin
        if (rst) begin
            axis_wrAddr <= 0;
            axis_write_num <= 0;
        end else if(slv_reg_wren && s_axis_tlast) begin
            axis_wrAddr <= 0;
            axis_write_num <= axis_wrAddr;
        end else if(slv_reg_wren) begin
            axis_wrAddr <= axis_wrAddr + 1'b1;
        end
    end

    genvar i;
    generate
        for( i = 0 ; i <= REG_NUM-1; i = i+1) begin
            always @( posedge clk )begin
                if (rst) begin
                    user_reg[i] <= 0;
                end else if (slv_reg_wren_vec[i]) begin
                    user_reg[i] <= s_axis_tdata;
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
            axi_araddr  <= 0;
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


`resetall