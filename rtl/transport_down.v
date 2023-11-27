module transport_down(
    input                       s_axis_aclk,
    input                       s_axis_aresetn,

    // axi stream fifo signals:
    output                      s_axis_tready,
    input      [63:0]           s_axis_tdata,
    input                       s_axis_tlast,
    input                       s_axis_tvalid,


    // PAICore Signals:
    input                       i_send_available,	// paicore ready to receive data
    output                      o_send_valid,
    output          [63:0]      o_send_pdata,   // paicore data.      

    output                      s_axis_hsked,

	// control signal:
	output                      o_tx_done
);

    assign s_axis_hsked  = s_axis_tready && s_axis_tvalid;

    assign o_send_valid  = s_axis_tvalid;
    assign o_send_pdata  = s_axis_tdata;
    assign s_axis_tready = i_send_available;

    assign o_tx_done = s_axis_hsked && s_axis_tlast;

endmodule
