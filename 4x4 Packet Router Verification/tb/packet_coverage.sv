

class packet_coverage;
  
  mailbox #(packet_trans) outMonToCov;
  int unsigned num_sampled;
  packet_trans temp;
  
    
  function new(mailbox #(packet_trans) outMonToCov);
    this.outMonToCov = outMonToCov;
    this.num_sampled = 0;
  endfunction
  
  task run();
    
    forever begin
      outMonToCov.get(temp);
      temp.cGroup.sample();
      num_sampled++;
    end
  endtask
  
  function void report();

    $display("========== PACKET COVERAGE REPORT ==========");
    $display(
    "Overall packet coverage: %0.2f%%",
    temp.cGroup.get_coverage()
    );

    $display(
    "Source coverage: %0.2f%%",
    temp.cGroup.cpSrc.get_coverage()
    );

    $display(
    "Destination coverage: %0.2f%%",
    temp.cGroup.cpDest.get_coverage()
    );

    $display(
    "Length coverage: %0.2f%%",
    temp.cGroup.cpLen.get_coverage()
    );

    $display(
    "Priority coverage: %0.2f%%",
    temp.cGroup.cpPriority.get_coverage()
    );

    $display(
    "Source x destination coverage: %0.2f%%",
    temp.cGroup.crossSrcDest.get_coverage()
    );
    $display("============================================");
  endfunction
endclass













