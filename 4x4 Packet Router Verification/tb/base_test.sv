
class base_test;
  
  router_env rEnv;
  
  
  function new(mailbox #(packet_trans) inMonToSb, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov, mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3, virtual router_if.inputDriverMp iDrv, virtual router_if.inputMonitorMp iMon, virtual router_if.outputReadyDriverMp oRDrv, virtual router_if.outputMonitorMp oMon);
    
        
    this.rEnv = new(Port0, Port1, Port2, Port3, inMonToSb, outMonToSb, outMonToCov, iDrv, iMon, oRDrv, oMon);
  endfunction
  
  
  
endclass








