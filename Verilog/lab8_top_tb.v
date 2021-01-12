// Testbench module for lab8_top
module lab8_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  // Module instantiation for the top level module DUT.
  lab8_top DUT(~KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);


  // Task module for self checking tests.
  task checker;  
    input exp_Z, exp_V, exp_N;

    begin
      if(lab8_top_tb.DUT.CPU.Z!== exp_Z) begin
        $display("Error: Z is %b, exp_Z is %b", 
            lab8_top_tb.DUT.CPU.Z, exp_Z);
        err = 1'b1;   // If test fails, displays expected and actual value of Z.
      end

      if(lab8_top_tb.DUT.CPU.V!== exp_V) begin
        $display("Error: V is %b, exp_V is %b", 
            lab8_top_tb.DUT.CPU.V, exp_V);
        err = 1'b1;   // If test fails, displays expected and actual value of V.
      end

      if(lab8_top_tb.DUT.CPU.N!== exp_N) begin
        $display("Error: N is %b, exp_N is %b", 
            lab8_top_tb.DUT.CPU.N, exp_N);
        err = 1'b1;   // If test fails, displays expected and actual value of N.
      end
    end
  endtask      

  initial forever begin
    KEY[0] = 0; #5; // Set clk to 1, then 0.
    KEY[0] = 1; #5;
  end

  initial begin
    //initialize err, reset, load, and in
    err = 0; 
    KEY[1] = 1'b1;

    // Memory address checks with memory in the data file.
    // if (DUT.MEM.mem[0] !== 16'b1101000000001010)  begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[1] !== 16'b0110000000100000)  begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[2] !== 16'b1101001000001011)  begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[3] !== 16'b0110001001100000)  begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[4] !== 16'b1000001000100000)  begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); $stop; end  
    // if (DUT.MEM.mem[5] !== 16'b1010000110001011)  begin err = 1; $display("FAILED: mem[5] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[6] !== 16'b1100000010110100)  begin err = 1; $display("FAILED: mem[6] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[7] !== 16'b1011010011000101)  begin err = 1; $display("FAILED: mem[7] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[8] !== 16'b1010110000001101)  begin err = 1; $display("FAILED: mem[8] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[9] !== 16'b1011100011100101)  begin err = 1; $display("FAILED: mem[9] wrong; please set data.txt using Figure 6"); $stop; end  
    // if (DUT.MEM.mem[10] !== 16'b0000000000010000) begin err = 1; $display("FAILED: mem[10] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[11] !== 16'b0000000000000101) begin err = 1; $display("FAILED: mem[11] wrong; please set data.txt using Figure 6"); $stop; end
    // if (DUT.MEM.mem[12] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[12] wrong; please set data.txt using Figure 6"); $stop; end  

    #10; // wait until next falling edge of clock
    KEY[1] = 0; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC

    $display("PC = %d", DUT.CPU.PC);  //PC 0
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R0, X

    $display("PC = %d", DUT.CPU.PC);  //PC 1    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R0, X

    $display("PC = %d", DUT.CPU.PC);  //PC 2
    if (DUT.CPU.DP.REGFILE.R0 !== 16'd14) begin err = 1; $display("FAILED: R0 should be 10."); $stop; end  // because MOV R0, X should have occurred
    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; LDR R1, [R0]
    $display("PC = %d", DUT.CPU.PC);  //PC 3
    if (DUT.CPU.DP.REGFILE.R1 !== 16'd16) begin err = 1; $display("FAILED: R1 should be 16"); $stop; end
    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R2, Y
    $display("PC = %d", DUT.CPU.PC);  //PC 4
    if (DUT.CPU.DP.REGFILE.R2 !== 16'd15) begin err = 1; $display("FAILED: R2 should be 11."); $stop; end
    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; STR R1, [R2]
    $display("PC = %d", DUT.CPU.PC);  //PC 5
    if (DUT.MEM.mem[15] !== 16'd5) begin err = 1; $display("FAILED: mem[15] wrong; looks like your STR isn't working"); $stop; end

    $display("PC = %d", DUT.CPU.PC);  //PC 6
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; ADD R4, R1, R3, LSL#1
    $display("PC = %d", DUT.CPU.PC);  //PC 7
    if (DUT.CPU.DP.REGFILE.R4 !== 16'd26) begin err = 1; $display("FAILED: R4 should be 26"); $stop; end
    
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R5, R4, LSR#1
    $display("PC = %d", DUT.CPU.PC);  //PC 8
    if (DUT.CPU.DP.REGFILE.R5 !== 16'd13) begin err = 1; $display("FAILED: R5 should be 13"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; AND R6, R4, R5 
    $display("PC = %d", DUT.CPU.PC);  //PC 9
    if (DUT.CPU.DP.REGFILE.R6 !== 16'b0000_0000_0000_1000) begin err = 1; $display("FAILED: R5 should be 0000_0000_0000_1000"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; CMP R4, R5, LSL#1
    $display("PC = %d", DUT.CPU.PC);  //PC 10
    checker(1'b1, 0, 0);

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MVN R7, R5 
    $display("PC = %d", DUT.CPU.PC);  //PC 11
    if (DUT.CPU.DP.REGFILE.R7 !== 16'b1111_1111_1111_0010) begin err = 1; $display("FAILED: R7 should be 1111_1111_1111_0010"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R1, #50
    $display("PC = %d", DUT.CPU.PC);  //PC 12
    if (DUT.CPU.DP.REGFILE.R1 !== 16'd50) begin err = 1; $display("FAILED: R1 should be 50 (decimal)"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; MOV R0, Z
    $display("PC = %d", DUT.CPU.PC);  //PC 13
    if (DUT.CPU.DP.REGFILE.R0 !== 16'd20) begin err = 1; $display("FAILED: R0 should be 20 (decimal)"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; STR R4, [R0], where R4 = 26, R0 = 108
    $display("PC = %d", DUT.CPU.PC);  //PC 14
    $display("mem[21] = %b", DUT.MEM.mem[21]);
    $display("mem[20] = %b", DUT.MEM.mem[20]);
    $display("mem[17] = %b", DUT.MEM.mem[17]);
    #50
    if (DUT.MEM.mem[17] !== 16'd15) begin err = 1; $display("FAILED: mem[17] wrong; looks like your STR isn't working"); $stop; end

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("ALL TESTS PASSED"); // If error signal is 0, then display PASSED.
    $stop;

  end
endmodule