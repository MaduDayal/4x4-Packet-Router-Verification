
class output_ready_driver;
  
  virtual router_if.outputReadyDriverMp oDrvMp;
  typedef enum {ALWAYS_READY, RANDOM_READY, BURST_STALL, PER_PORT_PATTERN} readyMode;
  readyMode mode;
  
  function new(virtual router_if.outputReadyDriverMp oDrvMp, readyMode mode = ALWAYS_READY);
    this.oDrvMp = oDrvMp;
    this.mode = mode;
  endfunction
  
  
  task run();
    oDrvMp.outRDriver.out_ready <= '0;
    
    wait(oDrvMp.outRDriver.RESET == 1'b0);
    
    forever begin
      case(mode)
        ALWAYS_READY: oDrvMp.outRDriver.out_ready <= 4'b1111;
        RANDOM_READY: begin
          for(int i = 0; i < 4; i++) begin
            randcase
              50: oDrvMp.outRDriver.out_ready[i] <= 1'b0;
              50: oDrvMp.outRDriver.out_ready[i] <= 1'b1;
            endcase
          end
        end
        BURST_STALL: begin
          repeat(5) begin
            @(oDrvMp.outRDriver);
            oDrvMp.outRDriver.out_ready <= 4'b1111;
          end
          repeat(3) begin
            @(oDrvMp.outRDriver);
            oDrvMp.outRDriver.out_ready <= 4'b0000;
          end
          
        end
        PER_PORT_PATTERN: begin
          oDrvMp.outRDriver.out_ready[0] <= 1'b1;
          oDrvMp.outRDriver.out_ready[3] <= 1'b1;
          randcase
          	70: oDrvMp.outRDriver.out_ready[1] <= 1'b0;
          	30: oDrvMp.outRDriver.out_ready[1] <= 1'b1;
          endcase
          randcase
          	30: oDrvMp.outRDriver.out_ready[2] <= 1'b0;
          	70: oDrvMp.outRDriver.out_ready[2] <= 1'b1;
          endcase
          
        end
      endcase
          
      @(oDrvMp.outRDriver);
    end
    
  endtask
  
  
endclass








