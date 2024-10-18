class virtual_seqs extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(virtual_seqs);

  // All sequencer handles
  source_sequencer s_seqr_h[];
  dest_sequencer d_seqr_h[];
  virtual_sequencer v_seqr_h;

  // All sequence handles
  // source sequences
  short_seqs s_short_seqs_h;
  medium_seqs s_medium_seqs_h;
  large_seqs s_large_seqs_h;

  // destination sequence
  less_delay_seqs d_less_delay_seqs_h;
  medium_delay_seqs d_medium_delay_seqs_h;
  large_delay_seqs d_large_delay_seqs_h;

  env_config e_cfg;

  bit [1:0] add;

  function new(string name = "virtual_seqs");
    super.new(name);
  endfunction

  task body();

    if (!uvm_config_db#(bit [1:0])::get(null, get_full_name(), "bit", add)) begin
      `uvm_fatal("virtual_seqs", "Set the address bit properly")
    end

    if (!uvm_config_db#(env_config)::get(null, get_full_name(), "env_config", e_cfg)) begin
      `uvm_fatal("virtual_seqs", "Set the env_config properly")
    end

    s_seqr_h = new[e_cfg.no_of_source_agt];
    d_seqr_h = new[e_cfg.no_of_dest_agt];

    assert ($cast(v_seqr_h, m_sequencer))
    else begin
      `uvm_error("VIRTUAL_SEQS", "Error in $cast of virtual sequencer")
    end

    foreach (s_seqr_h[i]) begin
      s_seqr_h[i] = v_seqr_h.s_seqr_h[i];
    end

    foreach (d_seqr_h[i]) begin
      d_seqr_h[i] = v_seqr_h.d_seqr_h[i];
    end

  endtask

endclass


class short_virtual_seqs extends virtual_seqs;

  `uvm_object_utils(short_virtual_seqs)

  function new(string name = "short_virtual_seqs");
    super.new(name);
  endfunction

  task body();

    super.body();

    s_short_seqs_h = short_seqs::type_id::create("s_short_seqs_h");
    d_less_delay_seqs_h = less_delay_seqs::type_id::create("d_less_delay_seqs_h");

    fork
      s_short_seqs_h.start(s_seqr_h[0]);
      d_less_delay_seqs_h.start(d_seqr_h[add]);
    join

  endtask

endclass

class medium_virtual_seqs extends virtual_seqs;

  `uvm_object_utils(medium_virtual_seqs)

  function new(string name = "medium_virtual_seqs");
    super.new(name);
  endfunction

  task body();

    super.body();

    s_medium_seqs_h = medium_seqs::type_id::create("s_medium_seqs_h");
    d_medium_delay_seqs_h = medium_delay_seqs::type_id::create("d_medium_delay_seqs_h");

    fork
      s_medium_seqs_h.start(s_seqr_h[0]);
      d_medium_delay_seqs_h.start(d_seqr_h[add]);
    join

  endtask

endclass

class large_virtual_seqs extends virtual_seqs;

  `uvm_object_utils(large_virtual_seqs)

  function new(string name = "large_virtual_seqs");
    super.new(name);
  endfunction

  task body();

    super.body();

    s_large_seqs_h = large_seqs::type_id::create("s_large_seqs_h");
    d_large_delay_seqs_h = large_delay_seqs::type_id::create("d_large_delay_seqs_h");

    fork
      s_large_seqs_h.start(s_seqr_h[0]);
      d_large_delay_seqs_h.start(d_seqr_h[add]);
    join

  endtask

endclass

class large_less_virtual extends virtual_seqs;

  `uvm_object_utils(large_less_virtual)

  function new(string name = "large_less_virtual");
    super.new(name);
  endfunction

  task body();

    super.body();

    s_large_seqs_h = large_seqs::type_id::create("s_large_seqs_h");
    d_less_delay_seqs_h = less_delay_seqs::type_id::create("d_less_delay_seqs_h");

    fork
      s_large_seqs_h.start(s_seqr_h[0]);
      d_less_delay_seqs_h.start(d_seqr_h[add]);
    join

  endtask

endclass
