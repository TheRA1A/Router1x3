class dest_seqs extends uvm_sequence #(dest_trans);

  `uvm_object_utils(dest_seqs);

  function new(string name = "dest_seqs");
    super.new(name);
  endfunction

endclass

class less_delay_seqs extends dest_seqs;

  `uvm_object_utils(less_delay_seqs)

  function new(string name = "less_delay_seqs");
    super.new(name);
  endfunction : new

  task body();

    req = dest_trans::type_id::create("req");

    start_item(req);
    `uvm_info("LESS_DELAY_SEQS", "start_item is unblocked", UVM_LOW)

    assert (req.randomize() with {delay inside {[1 : 15]};});

    finish_item(req);
    `uvm_info("LESS_DELAY_SEQS", "finish_item is unblocked", UVM_LOW)

  endtask

endclass


class medium_delay_seqs extends dest_seqs;

  `uvm_object_utils(medium_delay_seqs)

  function new(string name = "medium_delay_seqs");
    super.new(name);
  endfunction

  task body();

    req = dest_trans::type_id::create("req");

    start_item(req);
    `uvm_info("MEDIUM_DELAY_SEQS", "start_item is unblocked", UVM_LOW)

    assert (req.randomize() with {delay inside {[16 : 30]};});

    finish_item(req);
    `uvm_info("MEDIUM_DELAY_SEQS", "finish_item is unblocked", UVM_LOW)

  endtask : body

endclass


class large_delay_seqs extends dest_seqs;

  `uvm_object_utils(large_delay_seqs)

  function new(string name = "large_delay_seqs");
    super.new(name);
  endfunction

  task body();

    req = dest_trans::type_id::create("req");

    start_item(req);
    `uvm_info("LARGE_DELAY_SEQS", "start_item is unblocked", UVM_LOW)

    assert (req.randomize() with {delay == 40;});

    finish_item(req);
    `uvm_info("LARGE_DELAY_SEQS", "finish_item is unblocked", UVM_LOW)

  endtask


endclass












