
class output_monitor;
  
  virtual router_if.outputMonitorMp oMp;
  logic [15:0] outIndex [0:3];
  packet_trans temp [0:3];
  mailbox #(packet_trans) outMonToSb;
  mailbox #(packet_trans) outMonToCov;
  
  function new(virtual router_if.outputMonitorMp oMp, mailbox #(packet_trans) outMonToSb, mailbox #(packet_trans) outMonToCov);
    this.oMp = oMp;
    this.outIndex = '{default: 0};
    this.outMonToSb = outMonToSb;
    this.outMonToCov = outMonToCov;
  endfunction
  
  task run();
    fork
      monitor_port(0);
      monitor_port(1);
      monitor_port(2);
      monitor_port(3);
    join_none
    
  endtask
  
  task monitor_port(int i);
    packet_trans temps;    
    forever begin
      @(oMp.outMonitor);
      if(oMp.outMonitor.RESET) begin
        outIndex[i] = '0;
        temp[i] = new;
                
        while(outMonToSb.try_get(temps));
        while(outMonToCov.try_get(temps));
        continue;
      end
      if(oMp.outMonitor.out_valid[i] && oMp.outMonitor.out_ready[i] && oMp.outMonitor.out_sop[i]) begin
        temp[i] = new;
        outIndex[i] = '0;
        
        temp[i].headerBeat = oMp.outMonitor.out_data[i];
        temp[i].dest = temp[i].headerBeat[31:30];
        
        temp[i].src = temp[i].headerBeat[29:28];
        temp[i].len = temp[i].headerBeat[27:24];
        temp[i].payload = new[temp[i].len];
        
        temp[i].packID = temp[i].headerBeat[23:16];
        temp[i].prior = temp[i].headerBeat[15:14];
        
      end
      else if(oMp.outMonitor.out_valid[i] && oMp.outMonitor.out_ready[i] && !oMp.outMonitor.out_sop[i] && !oMp.outMonitor.out_eop[i]) begin
        temp[i].payload[outIndex[i]] = oMp.outMonitor.out_data[i];
        outIndex[i] = outIndex[i] + 1'b1;
      end
      else if(oMp.outMonitor.out_valid[i] && oMp.outMonitor.out_ready[i] && oMp.outMonitor.out_eop[i]) begin
        temp[i].payload[outIndex[i]] = oMp.outMonitor.out_data[i];
        
        temp[i].observedPort = i;
        outMonToSb.put(temp[i].copy());
        outMonToCov.put(temp[i].copy());
        outIndex[i] = '0;
      end
    end
    
  endtask
  
  
endclass




















