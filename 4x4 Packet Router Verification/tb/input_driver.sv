class input_driver;
  virtual router_if.inputDriverMp dMp;
  mailbox #(packet_trans) genToDrv0, genToDrv1, genToDrv2, genToDrv3;
  packet_trans obj [0:3];
  
  function new(virtual router_if.inputDriverMp dMp, mailbox #(packet_trans) genToDrv0, mailbox #(packet_trans) genToDrv1, mailbox #(packet_trans) genToDrv2, mailbox #(packet_trans) genToDrv3);
    this.dMp = dMp;
    this.genToDrv0 = genToDrv0;
    this.genToDrv1 = genToDrv1;
    this.genToDrv2 = genToDrv2;
    this.genToDrv3 = genToDrv3;
  endfunction
  
  task run();
    fork
      drive_port(0);
      drive_port(1);
      drive_port(2);
      drive_port(3);
    join_none
  endtask
  
  task drive_port(int i);
    packet_trans temps;
    
    @(dMp.inDriver);
        
    forever begin
      if(dMp.inDriver.RESET) begin
        dMp.inDriver.in_valid[i] <= 1'b0;
        dMp.inDriver.in_sop[i] <= 1'b0;
        dMp.inDriver.in_eop[i] <= 1'b0;
        dMp.inDriver.in_data[i] <= '0;
        
        obj[i] = new;
        
        @(dMp.inDriver);
        continue;
      end
      case(i)
        0: genToDrv0.get(obj[0]);
        1: genToDrv1.get(obj[1]);
        2: genToDrv2.get(obj[2]);
        3: genToDrv3.get(obj[3]);
      endcase
      
           
      @(dMp.inDriver);
      dMp.inDriver.in_valid[i] <= 1'b1;
      dMp.inDriver.in_sop[i] <= 1'b1;
      dMp.inDriver.in_eop[i] <= 1'b0;
      dMp.inDriver.in_data[i] <= obj[i].headerBeat;
      
      
      do begin
        @(dMp.inDriver);
      end while(dMp.inDriver.in_ready[i] == 1'b0);
      
      for(int j = 0; j < obj[i].len; j++) begin
        dMp.inDriver.in_valid[i] <= 1'b1;
        dMp.inDriver.in_sop[i] <= 1'b0;
        dMp.inDriver.in_data[i] <= obj[i].payload[j];
        
        if(j == obj[i].len - 1) begin
          dMp.inDriver.in_eop[i] <= 1'b1;
                              
        end
        else begin
          
          dMp.inDriver.in_eop[i] <= 1'b0;
        end
        do begin
          @(dMp.inDriver);
        end while(dMp.inDriver.in_ready[i] == 1'b0);
        
      end
      
      dMp.inDriver.in_valid[i] <= 1'b0;
      dMp.inDriver.in_sop[i] <= 1'b0;
      dMp.inDriver.in_eop[i] <= 1'b0;
      dMp.inDriver.in_data[i] <= '0;
    end
  endtask
  
  
endclass










