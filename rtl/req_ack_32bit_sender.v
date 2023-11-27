`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// ZhongYi@2021.01.19
//
// Module Function: 2-phase asynchronous handshake sender module
// 
// Description: send data according to 2-phase asynchronous handshake protocol.
// Every time 32-bit data is sent.
//
//output34 input 68
//
//////////////////////////////////////////////////////////////////////////////////
module req_ack_32bit_sender(
	clk,
	rstn,
	available,
	valid,
	din,
	request,
	acknowledge,
	dout
	);
	//---------------------------------------- PORT ----------------------------------------//
	//Group 1: clk and reset signals
	input                  rstn;         //this reset is synchronized
	input                  clk;         //clock

	//Group 2: data signals
	input      [63:0]      din;         //data from current chip
	output reg [31:0]      dout;        //data sent to other chip

	//Group 3: control signals
	input                  acknowledge; //acknowledge signal from other chip, this signal needs to be synchronized to clk
	output reg             request;     //request signal to other chip,
	input                  valid;       //indicate the input data from current chip is valid
	output reg             available;   //indicate the sender is available to send data 

	reg                    data_part;   //0:the 1st 32-bit data, 1:the 2nd 32-bit data
	reg        [31:0]      data_buf;    //store the 2nd 32-bit data
	reg                    ack_syn1;
	reg                    ack_syn2;
	reg                    ack_q;
	wire                   ack_pulse;
    reg                    rstn_r;
	reg                    flag;

	//synchronize acknowledge to current clk
	always @(posedge clk or negedge rstn)
	if(!rstn) 
		{ack_syn2, ack_syn1} <= 0;
	else 
		{ack_syn2, ack_syn1} <= {ack_syn1, acknowledge};//对ack信号进行延时
 
	//acknowledge from receiver to sender is a level signal
	//need to generate a pulse to acknowledge sender the transaction is complete
	always @(posedge clk or negedge rstn)
	if(!rstn)
		ack_q <= 1'b0;
	else
		ack_q <= ack_syn2;//再对ack延时
 
	assign ack_pulse = ack_syn2 ^ ack_q;//产生两个ack脉冲

	always @(posedge clk or negedge rstn)
	if(!rstn)
		request <= 1'b0;
	else if((valid & available) | (ack_pulse & ~data_part))
		request <= ~request;//如果外部可以传入信号且内部可以接收信号，或者收到应答信号且正要发送低32位，req信号反转
	
	always @(posedge clk or negedge rstn)
	if(!rstn)
		available <= 1'b1;
	else if(valid & available)
		available <= 1'b0;//如果外部可以传入信号且内部可以接收信号，则内部不能接收信号
	else if(ack_pulse & data_part)
		available <= 1'b1;//如果收到应答信号且刚发送完高32位，则内部可以接收信号
		                  

	always @(posedge clk or negedge rstn)
	if(!rstn)
		data_part <= 1'b0;
	else if(ack_pulse)
		data_part <= ~data_part;//两个ack用来先发高32位再发低32位	
 
	// latch the data
	always @(posedge clk or negedge rstn)
	if(!rstn) begin
		dout     <= 32'd0;
		data_buf <= 32'd0;
	end
	else if(valid & available) begin
		dout     <= din[63:32];
		data_buf <= din[31:0];//如果外部可以传入信号且内部可以接收信号，发送高32位
	end
	else if(ack_pulse & ~data_part) begin
		dout     <= data_buf;//如果收到第二个应答信号并且准备好发送低32位，则发送低32位
	end
	
endmodule