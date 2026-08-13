
class reset_test extends base_test;
  
  
  function new(mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
    
    super.new(Port0, Port1, Port2, Port3, inMonToSb, outMonToSb, outMonToCov, iDrv, iMon, oRDrv, oMon);
    
  endfunction
  
  
  task resetTest();
    wait(rEnv.inDriver.dMp.inDriver.RESET == 1'b0);
    rEnv.run();
    rEnv.packGen.randPacks(.N(4));
    
    wait(rEnv.inDriver.dMp.inDriver.RESET == 1'b1);
    
    rEnv.rScoreBoard.resetSb();
    rEnv.packGen.emptyMailboxes();
    
    wait(rEnv.inDriver.dMp.inDriver.RESET == 1'b0);
    rEnv.packGen.randPacks(.N(2));
    
    
    wait(rEnv.rScoreBoard.num_expected == 8 && rEnv.rScoreBoard.num_actual == 8 && rEnv.packCov.num_sampled == 24);
    rEnv.rScoreBoard.report();
    rEnv.packCov.report();
    
    $finish;
  endtask
  
  
  
  
  
endclass












