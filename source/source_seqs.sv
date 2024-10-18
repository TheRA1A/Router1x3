class source_seqs extends uvm_sequence #(source_trans);

  `uvm_object_utils(source_seqs);

  bit [1:0] add;

  function new(string name = "source_seqs");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(bit [1:0])::get(null, get_full_name(), "bit", add)) begin
      `uvm_fatal("DEST_SEQS", "Set the address bit properly")
    end
  endtask

endclass

class short_seqs extends source_seqs;

  `uvm_object_utils(short_seqs)

  // bit [1:0] add;

  function new(string name = "short_seqs");
    super.new(name);
  endfunction : new

  task body();

    super.body();

    req = source_trans::type_id::create("req");

    // if (!uvm_config_db#(bit [1:0])::get(null, get_full_name(), "bit", add)) begin
    //   `uvm_fatal("DEST_SEQS", "Set the address bit properly")
    // end

    start_item(req);
    `uvm_info("SHORT_SEQS", "start_item is unblocked", UVM_LOW)

    assert (req.randomize() with {
      payload.size inside {[1 : 14]};
      header[1:0] == add;
    });

    req.parity = 0;

    finish_item(req);
    `uvm_info("SHORT_SEQS", "finish_item is unblocked", UVM_LOW)

  endtask : body

endclass

class medium_seqs extends source_seqs;

  `uvm_object_utils(medium_seqs)

  function new(string name = "medium_seqs");
    super.new(name);
  endfunction : new

  task body();
    super.body();
    req = source_trans::type_id::create("req");
    start_item(req);
    `uvm_info("MEDIUM_SEQS", "start_item is unblocked", UVM_LOW)
    assert (req.randomize() with {
      payload.size inside {[21 : 40]};
      header[1:0] == add;
    });
    finish_item(req);
    `uvm_info("MEDIUM_SEQS", "finish_item is unblocked", UVM_LOW)
  endtask : body

endclass

class large_seqs extends source_seqs;

  `uvm_object_utils(large_seqs)

  function new(string name = "large_seqs");
    super.new(name);
  endfunction : new

  task body();
    super.body();
    req = source_trans::type_id::create("req");
    start_item(req);
    `uvm_info("LARGE_SEQS", "start_item is unblocked", UVM_LOW)
    assert (req.randomize() with {
      payload.size inside {[41 : 63]};
      header[1:0] == add;
    });
    finish_item(req);
    `uvm_info("LARGE_SEQS", "finish_item is unblocked", UVM_LOW)
  endtask : body

endclass


