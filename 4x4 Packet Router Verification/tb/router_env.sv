
class router_env;
    
  input_monitor inMonitor;
  input_driver inDriver;
  output_monitor outMonitor;
  output_ready_driver outRDriver;
  router_scoreboard rScoreBoard;
  packet_generator packGen;
  packet_coverage packCov;
  
  function new(mailbox #(packet_trans) genToDrv0, mailbox #(packet_trans) genToDrv1, mailbox #(packet_trans) genToDrv2, mailbox #(packet_trans) genToDrv3, mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
        
    this.inMonitor = new(iMon, inMonToSb);
    this.inDriver = new(iDrv, genToDrv0, genToDrv1, genToDrv2, genToDrv3);
    this.outMonitor = new(oMon, outMonToSb, outMonToCov);
    this.outRDriver = new(oRDrv);
    this.rScoreBoard = new(inMonToSb, outMonToSb);
    this.packGen = new(genToDrv0, genToDrv1, genToDrv2, genToDrv3);
    this.packCov = new(outMonToCov);
  endfunction
  
  task run();
    fork
      outRDriver.run();
      outMonitor.run();
      inDriver.run();
      inMonitor.run();
      rScoreBoard.run();
      packCov.run();
    join_none
    
  endtask
  
endclass


















