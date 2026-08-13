
class backpressure_test extends base_test;
  
  function new(mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
    
    super.new(Port0, Port1, Port2, Port3, inMonToSb, outMonToSb, outMonToCov, iDrv, iMon, oRDrv, oMon);
    
  endfunction
  
  // MODE Default: ALWAYS_READY
  // Other options: PER_PORT_PATTERN, BURST_STALL, RANDOM_READY 
  task backPressureTest();
    wait(rEnv.inMonitor.inM.inMonitor.RESET == 1'b0);
    
    // CHANGE mode here
    rEnv.outRDriver.mode = output_ready_driver::ALWAYS_READY;
    rEnv.run();
    
    rEnv.packGen.randPacks(.N(3));
    wait(rEnv.rScoreBoard.num_expected == 12 && rEnv.rScoreBoard.num_actual == 12 && rEnv.packCov.num_sampled == 12);
        
  endtask
  
  
  
endclass














