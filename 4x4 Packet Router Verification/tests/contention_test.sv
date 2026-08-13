

class contention_test extends base_test;
  
  
  
  function new(mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
    
    super.new(Port0, Port1, Port2, Port3, inMonToSb, outMonToSb, outMonToCov, iDrv, iMon, oRDrv, oMon);
    
  endfunction
  
  
  
  
  task contentionTest();
  	wait(rEnv.inDriver.dMp.inDriver.RESET == 1'b0);
    rEnv.run();
    
    for(int i = 0; i < 4; i++) begin
      packet_trans temp = new;
      void'(temp.randomize());
        
      temp.headerBeat[29:28] = i;
      temp.headerBeat[31:30] = 2;
        
      rEnv.packGen.dirPacks(temp.headerBeat, temp.payload);
    end
    
    wait(rEnv.rScoreBoard.num_expected == 4 && rEnv.rScoreBoard.num_actual == 4 && rEnv.packCov.num_sampled == 4);
    rEnv.rScoreBoard.report();
    rEnv.packCov.report();
    $finish;
  endtask
  
endclass

















