class packet_trans;
  rand logic [31:0] headerBeat;
  rand logic [31:0] payload[];
  rand logic [1:0] dest, src, prior;
  rand logic [3:0] len;
  logic [1:0] observedPort;
  logic [7:0] packID;
  static logic [7:0] nextPackID = '0;
  time creationTime;
  
  constraint size {
    payload.size() == len;
    len != '0;
    solve len before payload;
  }
  
  constraint hBeat {
    headerBeat[31:30] == dest;
    headerBeat[29:28] == src;
    headerBeat[27:24] == len;
    headerBeat[23:16] == packID;
    headerBeat[15:14] == prior;
    headerBeat[13:0] == '0;
    
    solve dest, src, len, prior before headerBeat;
  }
  
  covergroup cGroup;
    cpSrc: coverpoint src {
      bins port[] = {[0:3]};
    }
    
    cpDest: coverpoint dest {
      bins port[] = {[0:3]};
    }
    
    cpLen: coverpoint len {
      bins min = {1};
      bins normal = {[2:14]};
      bins max = {15};
      
      illegal_bins empty = {0};
    }
    
    cpPriority: coverpoint prior {
      bins priorities[] = {[0:3]};
  	}

  	crossSrcDest: cross cpSrc, cpDest;
    
    option.per_instance = 0;
  endgroup
  
  function new();
    packID = nextPackID;
    nextPackID += 1'b1;
    cGroup = new;
    creationTime = $time;
  endfunction
  
  function packet_trans copy();
    packet_trans c = new;
    nextPackID--;
    c.len = this.len;
    c.dest = this.dest;
    c.src = this.src;
    c.prior = this.prior;
    c.packID = this.packID;
    c.headerBeat = this.headerBeat;
    c.payload = this.payload;
    c.creationTime = this.creationTime;
    c.observedPort = this.observedPort;
    
    return c;
  endfunction
  
  function void summary();
    $display("========== PACKET SUMMARY ==========");
    $display("This is Packet ID %0d, coming from %0d, going to %0d, with %0d payloads, created at %0t", 		packID, src, dest, len, creationTime);
    $display("The Payload content:");
    foreach(payload[i]) begin
      $display("At payload index %0d, packet stores %0h.", i, payload[i]);
    end
    
  endfunction
  
  function logic compare(packet_trans inPack);
    if((inPack.packID == this.packID) && (inPack.src == this.src) && (inPack.dest == dest) && (inPack.prior == this.prior)
    && (inPack.len == this.len) && (inPack.headerBeat == this.headerBeat) && (inPack.payload == this.payload) && (inPack.observedPort == this.dest)) begin
      $display("... all fields match ...");
      return 1'b1;
    end
    
    $display("... all fields do not match ...");
    return 1'b0;
  endfunction
  
endclass









