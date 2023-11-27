`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// ZhongYi@2021.01.19
//
// Module Function: 2-phase asynchronous handshake receiver module
// 
// Description: receive data according to 2-phase asynchronous handshake protocol.
// Every time 32-bit data is received.
//
//input 36 output 66
//////////////////////////////////////////////////////////////////////////////////
module req_ack_32bit_receiver(
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
	input      [31:0]      din;         //data from other chip
	output reg [63:0]      dout;        //data sent to current chip

	//Group 2: control signals
	input                  request;     //request signal from other chip, this signal needs to be synchronized to clk
	output reg             acknowledge; //acknowledge signal to other chip
	input                  available;   //indicate the receiver is available to receive data
	output                 valid;       //request write fifo
	
	reg                    ready;       //indicate the output data to current chip is ready
	reg                    ready_q;
	reg                    data_part;   //0:the 1st 32-bit data, 1:the 2nd 32-bit data
	reg                    req_syn1;
	reg                    req_syn2; 
	reg                    req_q;
	wire                   req_pulse;

	//synchronize request to current clk
	always @(posedge clk or negedge rstn)
	if(!rstn) 
		{req_syn2, req_syn1} <= 0;
	else 
		{req_syn2, req_syn1} <= {req_syn1, request};
 
	//request from sender to receiver is a level signal
	//need to generate a pulse to inform receiver the arrival of new transaction
	always @(posedge clk or negedge rstn)
	if(!rstn)
		req_q <= 1'b0;
	else
		req_q <= req_syn2;
 
	assign req_pulse = req_syn2 ^ req_q;

	always @(posedge clk or negedge rstn)
	if(!rstn)
		acknowledge <= 1'b0;
	else if((ready & available) | (req_pulse & ~data_part))
		acknowledge <= ~acknowledge;
 
	always @(posedge clk or negedge rstn)
	if(!rstn)
		ready <= 1'b0;
	else if(req_pulse & data_part)
		ready <= 1'b1;
	else if(ready & available)
		ready <= 1'b0;

	always @(posedge clk or negedge rstn)
	if(!rstn)
		ready_q <= 1'b0;
	else
		ready_q <= ready;

	assign valid = ~ready & ready_q;

	always @(posedge clk or negedge rstn)
	if(!rstn)
		data_part <= 1'b0;
	else if(req_pulse)
		data_part <= ~data_part;
 
	// latch the data before valid is 1
	always @(posedge clk or negedge rstn)
	if(!rstn)
		dout <= 64'd0;
	else if(req_pulse & ~data_part)
		dout[63:32] <= din;
	else if(req_pulse & data_part)
		dout[31:0] <= din;
	
endmodule
