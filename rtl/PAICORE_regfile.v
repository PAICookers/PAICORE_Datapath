
`timescale 1 ns / 1 ps

`define RX_STATE_IDEL       2'b00
`define RX_STATE_RECEVING   2'b01
`define RX_STATE_DONE       2'b10
`define TX_STATE_IDEL       2'b00
`define TX_STATE_SENDING    2'b01
`define TX_STATE_DONE       2'b10

module PAICORE_regfile #
(
    // Users to add parameters here
    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 6
)
(
    // Users to add ports here
    input wire          i_rx_done  ,	// to reg0, update rxstate to done.
    output wire         o_rx_rcving,  // from reg0, inform rxstate is recving.
    input wire          i_tx_done  ,  // just use to debug, not to control.

    output [31:0]       send_len,
//    output [31:0]       ctrl,
    output [31:0]       oFrameNumMax,
    output  [2:0]       PAICORE_CTRL,
    input  [63:0]       write_data,
    input  [63:0]       read_data,
    output              DataPath_Reset_n,

    input  [31:0]       data_cnt,
    input  [31:0]       tlast_cnt,
    
    input               cpu2fifo_plus ,
    input               fifo2snn_plus ,
    input               snn2fifo_plus ,
    input               fifo2cpu_plus ,

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
        // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
        // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
        // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
        // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
        // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
        // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
        // accept the read data and response information.
    input wire  S_AXI_RREADY
);
//    assign PAICORE_CTRL = 1'b0;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 16
    // reg0: rxstate, 0: IDLE, 1: RECVING, 2: DONE.
    // reg1: debug: txstate. 0: IDLE, 1: SENDING, 2: DONE.
    // reg2: debug: cpu2fifo_cnt.          RW
    // reg3: debug: fifo2snn_cnt.          RW
    // reg4: debug: snn2fifo_cnt.          RW
    // reg5: debug: fifo2cpu_cnt.          RW
    // reg6: debug: write_data[31:0].      RO
    // reg7: debug: write_data[63:32].     RO
    // reg8: debug: read_data[31:0].       RO
    // reg9: debug: read_data[63:32].      RO
    // reg10: debug: data_cnt.             RO
    // reg11: debug: tlast_cnt.            RO
    // reg12: debug: send_len.             WO
    // reg13: debug: ctrl.                 WO
    // reg14: make outputFrameNum known    WO  oFrameNumMax
    // reg15: reserved.
    reg [C_S_AXI_DATA_WIDTH-1:0]	uesr_reg [15:0];

    // Add user logic here
    reg  rx_done_delay, tx_done_delay;
    wire rx_done_pulse, tx_done_pulse; 
    wire [1:0] rx_state, tx_state;

    always @(posedge S_AXI_ACLK) begin
        rx_done_delay <= i_rx_done;
        tx_done_delay <= i_tx_done;
    end

    assign rx_done_pulse = i_rx_done & ~rx_done_delay;
    assign tx_done_pulse = i_tx_done & ~tx_done_delay;

    assign rx_state     = uesr_reg[0][1:0];
    assign tx_state     = uesr_reg[1][1:0];

    assign o_rx_rcving = (rx_state == `RX_STATE_RECEVING); // config by PS, to avoid interference caused by done signals during startup

    assign send_len         = uesr_reg[12];
    assign PAICORE_CTRL     = uesr_reg[13][2:0];
    assign oFrameNumMax     = uesr_reg[14];
    assign DataPath_Reset_n = uesr_reg[15][0];
    // wire cpu2fifo_plus = i_cpu2fifo_valid & i_cpu2fifo_ready; // debug_signals.
    // wire fifo2snn_plus = i_fifo2snn_valid & i_fifo2snn_ready; // debug_signals.
    // wire snn2fifo_plus = i_snn2fifo_valid & i_snn2fifo_ready; // debug_signals.
    // wire fifo2cpu_plus = i_fifo2cpu_valid & i_fifo2cpu_ready; // debug_signals.

    // User logic ends

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg                             axi_awready;
    reg                             axi_wready;
    reg [1 : 0]                     axi_bresp;
    reg                             axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg                             axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]                     axi_rresp;
    reg                             axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 3;

    reg [C_S_AXI_DATA_WIDTH-1:0]    reg_data_out;
    wire                            slv_reg_rden, slv_reg_wren;
    integer                         byte_index;
    reg                             aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY	 = axi_wready;
    assign S_AXI_BRESP	 = axi_bresp;
    assign S_AXI_BVALID	 = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA	 = axi_rdata;
    assign S_AXI_RRESP	 = axi_rresp;
    assign S_AXI_RVALID	 = axi_rvalid;
    // Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_awready <= 1'b0;
        aw_en <= 1'b1;
        end
    else
        begin
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
                begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
                end
        else           
            begin
            axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both 
    // S_AXI_AWVALID and S_AXI_WVALID are valid. 

    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_awaddr <= 0;
        end
    else
        begin
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
            // Write Address latching 
            axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    // de-asserted when reset is low. 

    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_wready <= 1'b0;
        end 
    else
        begin    
        if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
            // slave is ready to accept write data when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_wready <= 1'b1;
            end
        else
            begin
            axi_wready <= 1'b0;
            end
        end 
    end       

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    reg [15:0] axi_reg_sel, slv_reg_wren_vec;

    // assign axi_reg_sel = 4'b0001 << (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] + 1);

    always @(*) begin
        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            4'd0:    axi_reg_sel = 16'b0000_0000_0000_0001; 
            4'd1:    axi_reg_sel = 16'b0000_0000_0000_0010;
            4'd2:    axi_reg_sel = 16'b0000_0000_0000_0100;
            4'd3:    axi_reg_sel = 16'b0000_0000_0000_1000;
            4'd4:    axi_reg_sel = 16'b0000_0000_0001_0000;
            4'd5:    axi_reg_sel = 16'b0000_0000_0010_0000;
            4'd6:    axi_reg_sel = 16'b0000_0000_0100_0000;
            4'd7:    axi_reg_sel = 16'b0000_0000_1000_0000;
            4'd8:    axi_reg_sel = 16'b0000_0001_0000_0000;
            4'd9:    axi_reg_sel = 16'b0000_0010_0000_0000;
            4'd10:   axi_reg_sel = 16'b0000_0100_0000_0000;
            4'd11:   axi_reg_sel = 16'b0000_1000_0000_0000;
            4'd12:   axi_reg_sel = 16'b0001_0000_0000_0000;
            4'd13:   axi_reg_sel = 16'b0010_0000_0000_0000;
            4'd14:   axi_reg_sel = 16'b0100_0000_0000_0000;
            4'd15:   axi_reg_sel = 16'b1000_0000_0000_0000;
            default: axi_reg_sel = 16'b0;
        endcase
        slv_reg_wren_vec = axi_reg_sel & {16{slv_reg_wren}};
    end

    // user reg 0, rx_state:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[0] <= 0;
        end else if (rx_done_pulse) begin
            uesr_reg[0] <= {30'b0,`RX_STATE_DONE};
        end	else if (slv_reg_wren_vec[0])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[0][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end
    end

    // user reg 1, tx_state:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[1] <= 0;
        end else if (tx_done_pulse) begin
            uesr_reg[1] <= {30'b0,`TX_STATE_DONE};
        end	else if (slv_reg_wren_vec[1])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[1][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end
    end

    // user reg 2, cpu2fifo_cnt:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[2] <= 0;
        end else if (slv_reg_wren_vec[2])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[2][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end else if (cpu2fifo_plus) begin
            uesr_reg[2] <= uesr_reg[2] + 1;
        end
    end

    // user reg 3, fifo2snn_cnt:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[3] <= 0;
        end else if (slv_reg_wren_vec[3])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[3][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end else if (fifo2snn_plus) begin
            uesr_reg[3] <= uesr_reg[3] + 1;
        end
    end

    // user reg 4, snn2fifo_cnt:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[4] <= 0;
        end else if (slv_reg_wren_vec[4])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[4][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end else if (snn2fifo_plus) begin
            uesr_reg[4] <= uesr_reg[4] + 1;
        end
    end

    // user reg 5, fifo2cpu_cnt:
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[5] <= 0;
        end else if (slv_reg_wren_vec[5])begin
            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    uesr_reg[5][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                end
        end else if (fifo2cpu_plus) begin
            uesr_reg[5] <= uesr_reg[5] + 1;
        end
    end

    // user reg6\7_write_data
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[6] <= 0;
            uesr_reg[7] <= 0;
        end else if(cpu2fifo_plus)begin
            uesr_reg[6] <= write_data[31:0];
            uesr_reg[7] <= write_data[63:32];
        end
    end

    // user reg8\9_read_data
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[8] <= 0;
            uesr_reg[9] <= 0;
        end else if(fifo2cpu_plus)begin
            uesr_reg[8] <= read_data[31:0];
            uesr_reg[9] <= read_data[63:32];
        end
    end

    // user reg10\11_read_data
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
        if (~S_AXI_ARESETN) begin
            uesr_reg[10] <= 0;
            uesr_reg[11] <= 0;
        end else begin
            uesr_reg[10] <= data_cnt;
            uesr_reg[11] <= tlast_cnt;
        end
    end

    genvar i;
    generate
        for( i = 12 ; i <= 15; i = i+1) begin
            always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin
                if (~S_AXI_ARESETN) begin
                    uesr_reg[i] <= 0;
                end else if (slv_reg_wren_vec[i])begin
                    for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                        if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                            uesr_reg[i][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                        end
                end
            end
        end
    endgenerate

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
        end 
    else
        begin    
        if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
            end                   // work error responses in future
        else
            begin
            if (S_AXI_BREADY && axi_bvalid) 
                //check if bready is asserted while bvalid is high) 
                //(there is a possibility that bready is always asserted high)   
                begin
                axi_bvalid <= 1'b0; 
                end  
            end
        end
    end   

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when S_AXI_ARVALID is 
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_arready <= 1'b0;
        axi_araddr  <= 32'b0;
        end 
    else
        begin    
        if (~axi_arready && S_AXI_ARVALID)
            begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= S_AXI_ARADDR;
            end
        else
            begin
            axi_arready <= 1'b0;
            end
        end 
    end       

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
        end 
    else
        begin    
        if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
            end   
        else if (axi_rvalid && S_AXI_RREADY)
            begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
            end                
        end
    end    

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*)
    begin
        // Address decoding for reading registers
        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            4'h0   : reg_data_out <= uesr_reg[0];
            4'h1   : reg_data_out <= uesr_reg[1];
            4'h2   : reg_data_out <= uesr_reg[2];
            4'h3   : reg_data_out <= uesr_reg[3];
            4'h4   : reg_data_out <= uesr_reg[4];
            4'h5   : reg_data_out <= uesr_reg[5];
            4'h6   : reg_data_out <= uesr_reg[6];
            4'h7   : reg_data_out <= uesr_reg[7];
            4'h8   : reg_data_out <= uesr_reg[8];
            4'h9   : reg_data_out <= uesr_reg[9];
            4'hA   : reg_data_out <= uesr_reg[10];
            4'hB   : reg_data_out <= uesr_reg[11];
            4'hC   : reg_data_out <= uesr_reg[12];
            4'hD   : reg_data_out <= uesr_reg[13];
            4'hE   : reg_data_out <= uesr_reg[14];
            4'hF   : reg_data_out <= uesr_reg[15];
            default : reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN )
    begin
    if ( S_AXI_ARESETN == 1'b0 )
        begin
        axi_rdata  <= 0;
        end 
    else
        begin    
        // When there is a valid read address (S_AXI_ARVALID) with 
        // acceptance of read address by the slave (axi_arready), 
        // output the read dada 
        if (slv_reg_rden)
            begin
            axi_rdata <= reg_data_out;     // register read data
            end   
        end
    end    

endmodule
