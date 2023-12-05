module iverilog_dump();
initial begin
    $dumpfile("PAICORE_LoopBack.fst");
    $dumpvars(0, PAICORE_LoopBack);
end
endmodule
