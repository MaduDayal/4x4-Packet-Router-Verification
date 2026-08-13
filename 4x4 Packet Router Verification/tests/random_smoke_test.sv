
class random_smoke_test extends base_test;
  
  
  function new(mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
    
    super.new(Port0, Port1, Port2, Port3, inMonToSb, outMonToSb, outMonToCov, iDrv, iMon, oRDrv, oMon);
    
  endfunction
  
  
  task smokeTest(input int numSets);
    wait(rEnv.inMonitor.inM.inMonitor.RESET == 1'b0);
    rEnv.run();
    rEnv.packGen.randPacks(.N(numSets));
    
    wait(rEnv.rScoreBoard.num_expected == 4*numSets && rEnv.rScoreBoard.num_actual == 4*numSets && rEnv.packCov.num_sampled == 4*numSets);
    rEnv.rScoreBoard.report();
    rEnv.packCov.report();
    $finish;
  endtask
  
endclass













