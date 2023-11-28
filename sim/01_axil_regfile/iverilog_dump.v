module iverilog_dump();
initial begin
    $dumpfile("axil_regfile.fst");
    $dumpvars(0, axil_regfile);
end
endmodule
