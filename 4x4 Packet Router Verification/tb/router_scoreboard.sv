
class router_scoreboard;
  mailbox #(packet_trans) fromOut;
  mailbox #(packet_trans) fromIn;
  
  packet_trans expected[logic [7:0]]; 
  
  int num_expected;
  int num_actual;
  int num_pass;
  int num_fail;
  int num_unexpected;
  
  function new(mailbox #(packet_trans) fromIn, mailbox #(packet_trans) fromOut);
    this.fromIn = fromIn;
    this.fromOut = fromOut;
    
    this.num_expected = 0;
    this.num_actual = 0;
    this.num_pass = 0;
    this.num_fail = 0;
    this.num_unexpected = 0;
  endfunction
  
  task run();
    fork
      collect_expected();
      check_actual();
    join_none
        
  endtask
  
  task collect_expected();
    packet_trans exp;
    
    forever begin
      fromIn.get(exp);
      expected[exp.packID] = exp.copy();
      this.num_expected++;
    end
  endtask
  
  task check_actual();
    packet_trans act;
    packet_trans exp;
    
    forever begin
      fromOut.get(act);
      this.num_actual++;
      
      if(expected.exists(act.packID)) begin
        exp = expected[act.packID];
        
        matchSb: assert(exp.compare(act))
          this.num_pass++;
        else begin
          this.num_fail++;
          $error("The expected and actual packets do not match.");
          act.summary();
          exp.summary();
        end
        
        expected.delete(act.packID);
      end
      else begin
        $error("The output packID %0h does not match any expected packIDs.", act.packID);
        this.num_unexpected++;
        this.num_fail++;
      end
    
    end    
    
  endtask
  
  function void report();
    $display("========== ROUTER SCOREBOARD REPORT ==========");
    $display("Expected packets received: %0d", this.num_expected);
    $display("Actual packets received: %0d", this.num_actual);
    $display("Packets passed: %0d", this.num_pass);
    $display("Packets failed: %0d", this.num_fail);
    $display("Unexpected packets: %0d", this.num_unexpected);
    $display("Missing packets: %0d", expected.num());
    
    $display("");
    
    if(this.num_fail == 0 && this.num_expected == this.num_actual && this.num_unexpected == 0 && expected.num() == 0) begin
      $display("TEST PASSED");
    end
    else $display("TEST FAILED, %0d failures and %0d missing packets.", this.num_fail, expected.num());
    
    $display("==============================================");
    
  endfunction
  
  task resetSb();
    expected.delete();
    this.num_expected = 0;
  	this.num_actual = 0;
  	this.num_pass = 0;
  	this.num_fail = 0;
  	this.num_unexpected = 0;
    
  endtask
  
endclass














