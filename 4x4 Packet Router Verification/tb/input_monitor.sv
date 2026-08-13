

class input_monitor;
  
  virtual router_if.inputMonitorMp inM;
  mailbox #(packet_trans) monSb;
  packet_trans temp [0:3];
  logic [15:0] writeIndex [0:3];
  
  function new(virtual router_if.inputMonitorMp inM, mailbox #(packet_trans) monSb);
    this.inM = inM;
    this.monSb = monSb;
    
    this.writeIndex = '{default: 0};
    
    foreach(temp[i]) begin
      temp[i] = new;
    end
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
      @(inM.inMonitor);
      if(inM.inMonitor.RESET) begin
        writeIndex[i] = '0;
        temp[i] = new;
        
        while(monSb.try_get(temps));
        continue;
      end
      if(inM.inMonitor.in_valid[i] && inM.inMonitor.in_ready[i] && inM.inMonitor.in_sop[i]) begin
        temp[i] = new;
        temp[i].headerBeat = inM.inMonitor.in_data[i];
        
        temp[i].dest = temp[i].headerBeat[31:30];
        temp[i].src = temp[i].headerBeat[29:28];
        temp[i].len = temp[i].headerBeat[27:24];
        temp[i].packID = temp[i].headerBeat[23:16];
        temp[i].prior = temp[i].headerBeat[15:14];
		
        temp[i].payload = new[temp[i].len];
        writeIndex[i] = '0;
        
      end
      else if(inM.inMonitor.in_valid[i] && inM.inMonitor.in_ready[i] && !inM.inMonitor.in_sop[i] && !inM.inMonitor.in_eop[i]) begin
        temp[i].payload[writeIndex[i]] = inM.inMonitor.in_data[i];
        writeIndex[i] = writeIndex[i] + 1'b1;
        
      end
      else if(inM.inMonitor.in_valid[i] && inM.inMonitor.in_ready[i] && inM.inMonitor.in_eop[i]) begin
        temp[i].payload[writeIndex[i]] = inM.inMonitor.in_data[i];
        monSb.put(temp[i]);
        writeIndex[i] = '0;
      end
      
    end
  endtask
  
endclass











