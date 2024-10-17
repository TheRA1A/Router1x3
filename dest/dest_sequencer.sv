class dest_sequencer extends uvm_sequencer #(dest_trans);

  `uvm_component_utils(dest_sequencer);


  function new(string name = "dest_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
