// Code your testbench here
// or browse Examples

// 6 TESTS - randomized, direct, contention, all possible paths, reset, and backpressure
// Source x Destination is a cross coverage - 16 POSSIBLE PATHS through ROUTER

module topModule;
  logic CLK, RESET;
  
  initial begin
    CLK = 1'b0;
    
  end
  
  always begin
    #5ns;
    CLK = ~CLK;
  end
  
  router_if rIf(.CLK(CLK), .RESET(RESET));
  mailbox #(packet_trans) genToDrv0 = new;
  mailbox #(packet_trans) genToDrv1 = new;
  mailbox #(packet_trans) genToDrv2 = new;
  mailbox #(packet_trans) genToDrv3 = new;
  mailbox #(packet_trans) inMonToSb = new;
  mailbox #(packet_trans) outMonToSb = new;
  mailbox #(packet_trans) outMonToCov = new;
  
  
  packet_router DUT(.dMod(rIf.DUTMp));
  
  // Backpressure tests MODES: ALWAYS_READY(Default), PER_PORT_PATTERN, BURST_STALL, RANDOM_READY
  // CHANGE MODE: Line 16 in backpressure_test.sv
  
  initial begin
    backpressure_test bTest;
    $display("Starting Backpressure test...");
    
    RESET = 1'b1;
    repeat(5) @(posedge CLK);
    RESET = 1'b0;
    
    bTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
    
    fork
      bTest.backPressureTest();
      begin
        repeat(2000) @(posedge CLK);
        bTest.rEnv.rScoreBoard.report();
        bTest.rEnv.packCov.report();
        $finish;
      end
      
    join_none
  end
  
  
  
  
  
  
  // Tests routing through all possible input ports to output port 2
  /*
  initial begin
    contention_test cTest;
    $display("Starting contention test...");
    
    RESET = 1'b1;
    repeat(5) @(posedge CLK);
    RESET = 1'b0;
    
    cTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
    
    cTest.contentionTest();
  end
  */
  
  
  
  
  
  
  // Sends 16 packets through router, then resets, and sends 8 packets -> outputs score report
  /*
  initial begin
    reset_test rTest;
    
    $display("Starting reset test...");
    RESET = 1'b1;
    
    repeat(5) @(posedge CLK);
    
    RESET = 1'b0;
    
        
    rTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
    
    fork
      
      rTest.resetTest();
      
      begin

        wait(
          rTest.rEnv.rScoreBoard.num_expected == 16 &&
          rTest.rEnv.rScoreBoard.num_actual == 16 && rTest.rEnv.rScoreBoard.expected.num() == 0 && 
          rTest.rEnv.packCov.num_sampled == 16
        );

        RESET = 1'b1;

        repeat(5) @(posedge CLK);

        RESET = 1'b0;
      
      end
      
    join_none
  end
  */
  
  
  
  
  
  // Tests for all possible 16 input/output port combinations
  /*
  initial begin
    possible_routes_test prTest;
    $display("Starting all possible routes test...");
    
    RESET = 1'b1;
    repeat(5) @(posedge CLK);
    RESET = 1'b0;
    prTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
    
    
    prTest.possibleRoutesTest();
  end
  */
  
  
  
  
  
  // Tests 60 randomly generated packets through packet router
  /*
  initial begin
  	random_smoke_test sTest;
    $display("Starting randomized packet test...");
    
    RESET = 1'b1;
    repeat(5) @(posedge CLK);
    RESET = 1'b0;
    sTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
    
    sTest.smokeTest(.numSets(15)); // CHANGE 15 to get N*4 random packets
    
  end
  */
  
  
  
  
  
  
  // Tests single packet through router
  /*
  initial begin
  	direct_smoke_test dTest;
    logic [31:0] testPack [0:2];
    $display("Starting direct single packet test...");
    
  	RESET = 1'b1;
    repeat(5) @(posedge CLK);
    RESET = 1'b0;
    dTest = new(inMonToSb, outMonToSb, outMonToCov, genToDrv0, genToDrv1, genToDrv2, genToDrv3, rIf.inputDriverMp, rIf.inputMonitorMp, rIf.outputReadyDriverMp, rIf.outputMonitorMp);
        
    testPack[0] = 32'hDEAD_BEEF;
    testPack[1] = 32'hCAFE_BABE;
    testPack[2] = 32'h1234_5678;
    
    dTest.directSmokeTest(32'h8321_4000, testPack);
  end
  */


endmodule




