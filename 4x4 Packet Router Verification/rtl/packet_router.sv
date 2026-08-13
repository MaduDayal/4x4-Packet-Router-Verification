module packet_router(router_if.DUTMp dMod);
 
  typedef enum {EMPTY, RECEIVING, FULL} portState;
  typedef enum {OUT_IDLE, OUT_SEND} outState;
  
  portState states [0:3];
  outState outStates [0:3];
  
  logic [31:0] packet_buffer [0:3][0:15];
  logic [1:0] portDest [0:3];
  logic [1:0] selInput [0:3];
  logic [3:0] sendIndex [0:3];
  
  logic [3:0] len [0:3];
  logic [3:0] writeIndex [0:3];
  logic [3:0] buffer_valid;
    
  always_ff @(posedge dMod.CLK) begin
    if(dMod.RESET) begin
      foreach(states[i]) states[i] <= EMPTY;
      writeIndex <= '{default: 0};
      portDest <= '{default: 0};
      len <= '{default: 0};
      buffer_valid <= '0;
      packet_buffer <= '{default: 0};
      foreach(outStates[i]) outStates[i] <= OUT_IDLE;
      sendIndex <= '{default: 0}; selInput <= '{default: 0};
    end
    else begin
      foreach(states[i]) begin
        case(states[i])
          EMPTY: begin
            buffer_valid[i] <= 1'b0;
            
            if(dMod.in_valid[i] && dMod.in_ready[i] && dMod.in_sop[i]) begin
              packet_buffer[i][0] <= dMod.in_data[i];
              portDest[i] <= dMod.in_data[i][31:30];
              len[i] <= dMod.in_data[i][27:24];
              writeIndex[i] <= 4'b0001;
              states[i] <= RECEIVING;
            end
          end

          RECEIVING: begin

            if(dMod.in_valid[i]) begin
              packet_buffer[i][writeIndex[i]] <= dMod.in_data[i];
              
            end
            
            if(dMod.in_eop[i] && dMod.in_valid[i]) begin
              states[i] <= FULL;
              buffer_valid[i] <= 1'b1;
            end
            if(!dMod.in_eop[i] && dMod.in_valid[i]) begin
              writeIndex[i] <= writeIndex[i] + 1'b1;
            end
          end

          FULL: begin
            
          end
          default: states[i] <= EMPTY;
        endcase
		
      end
      foreach(outStates[j]) begin
        case(outStates[j])
          OUT_IDLE: begin
            
            if(buffer_valid[0] && portDest[0] == j) begin
              selInput[j] <= 0;
              sendIndex[j] <= 0;
              outStates[j] <= OUT_SEND;
            end
            else if(buffer_valid[1] && portDest[1] == j) begin
              selInput[j] <= 1;
              sendIndex[j] <= 0;
              outStates[j] <= OUT_SEND;
            end
            else if(buffer_valid[2] && portDest[2] == j) begin
              selInput[j] <= 2;
              sendIndex[j] <= 0;
              outStates[j] <= OUT_SEND;
            end
            else if(buffer_valid[3] && portDest[3] == j) begin
              selInput[j] <= 3;
              sendIndex[j] <= 0;
              outStates[j] <= OUT_SEND;
            end
          end

          OUT_SEND: begin
                       
            if(dMod.out_ready[j]) begin
              if(sendIndex[j] == len[selInput[j]]) begin
                buffer_valid[selInput[j]] <= 1'b0;
                states[selInput[j]] <= EMPTY;
                outStates[j] <= OUT_IDLE;
                sendIndex[j] <= 1'b0;
              end
              else sendIndex[j] <= sendIndex[j] + 1'b1;
            end
          end
          default: outStates[j] <= OUT_IDLE;
        endcase
      end
    end
	
  end
  
  always_comb begin
    dMod.out_valid = '0;
    dMod.out_data = '{default: 0};
    dMod.out_sop = '0;
    dMod.out_eop = '0;
    dMod.in_ready = '0;
    
    if(dMod.RESET) dMod.in_ready = '0;
    
    foreach(states[i]) begin
      case(states[i])
        EMPTY: dMod.in_ready[i] = 1'b1;
        RECEIVING: dMod.in_ready[i] = 1'b1;
        FULL: dMod.in_ready[i] = 1'b0;
      endcase
    end
    
    foreach(outStates[j]) begin
      if(outStates[j] == OUT_SEND) begin
        dMod.out_valid[j] = 1'b1;
        dMod.out_data[j] = packet_buffer[selInput[j]][sendIndex[j]];
        if(sendIndex[j] == 1'b0) dMod.out_sop[j] = 1'b1;
        if(sendIndex[j] == len[selInput[j]]) dMod.out_eop[j] = 1'b1;
      end
    end
  end
  
  
endmodule










