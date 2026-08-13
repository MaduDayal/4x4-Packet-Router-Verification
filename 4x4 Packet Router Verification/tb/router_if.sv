interface router_if(input logic CLK, input logic RESET);
  
  logic [3:0] in_valid, in_ready, in_sop, in_eop;
  logic [31:0] in_data [0:3];
  
  logic [3:0] out_valid, out_ready, out_sop, out_eop;
  logic [31:0] out_data [0:3];
  
  
  clocking inDriver @(posedge CLK);
    input #2ns in_ready, RESET;
    output #3ns in_valid, in_data, in_sop, in_eop;
  endclocking
  
  clocking outRDriver @(posedge CLK);
    input #2ns out_valid, out_data, out_sop, out_eop, RESET;
    output #3ns out_ready;
  endclocking
  
  clocking inMonitor @(posedge CLK);
    input #2ns in_ready, in_valid, in_data, in_sop, in_eop, RESET;
  endclocking
  
  clocking outMonitor @(posedge CLK);
    input #3ns out_valid, out_data, out_ready, out_sop, out_eop, RESET;
  endclocking
  
  modport inputDriverMp(clocking inDriver);
  modport inputMonitorMp(clocking inMonitor);
  modport outputReadyDriverMp(clocking outRDriver);
  modport outputMonitorMp(clocking outMonitor);
  
  modport DUTMp(input CLK, input RESET, input in_valid, input in_data, input in_sop, input in_eop, input out_ready, 
               output out_valid, output out_data, output out_sop, output out_eop, output in_ready);
endinterface











