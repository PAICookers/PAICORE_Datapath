module iverilog_dump();
initial begin
    $dumpfile("axil_regfile_axis_wr.fst");
    $dumpvars(0, axil_regfile_axis_wr);
end
endmodule
