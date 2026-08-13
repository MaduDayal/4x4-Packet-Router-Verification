
class packet_generator;
  
  mailbox #(packet_trans) Port0;
  mailbox #(packet_trans) Port1;
  mailbox #(packet_trans) Port2;
  mailbox #(packet_trans) Port3;
  
  function new( mailbox #(packet_trans) Port0, mailbox #(packet_trans) Port1, mailbox #(packet_trans) Port2, mailbox #(packet_trans) Port3);
    this.Port0 = Port0;
    this.Port1 = Port1;
    this.Port2 = Port2;
    this.Port3 = Port3;
  endfunction
  
  // Every run from 1-N generates 4 packets
  task randPacks(input int N);
    
    packet_trans packs [0:3];
    
    repeat(N) begin
      foreach(packs[i]) begin
        packs[i] = new;
        if(packs[i].randomize()) begin
          case(packs[i].src)
            2'b00: Port0.put(packs[i]);
            2'b01: Port1.put(packs[i]);
            2'b10: Port2.put(packs[i]);
            2'b11: Port3.put(packs[i]);
          endcase
        end
        else $error("Packet Randomization fails");
        
      end
      
      
    end
  endtask
  
  task dirPacks(input logic [31:0] headerBeat, input logic [31:0] payload[]);
    packet_trans temp = new;
    
    temp.headerBeat = headerBeat;
    temp.payload = payload;
    
    temp.dest = headerBeat[31:30];
    temp.src = headerBeat[29:28];
    temp.len = headerBeat[27:24];
    temp.packID = headerBeat[23:16];
    temp.prior = headerBeat[15:14];
    
    case(temp.src)
      0: Port0.put(temp);
      1: Port1.put(temp);
      2: Port2.put(temp);
      3: Port3.put(temp);
      
    endcase
    
  endtask
  
  task emptyMailboxes();
    packet_trans temps;
    
    while(Port0.try_get(temps));
    while(Port1.try_get(temps));
    while(Port2.try_get(temps));
    while(Port3.try_get(temps));
  endtask
  
endclass











