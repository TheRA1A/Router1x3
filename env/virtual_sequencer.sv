class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(virtual_sequencer);

  source_sequencer s_seqr_h[];
  dest_sequencer d_seqr_h[];

  env_config e_cfg;

  function new(string name = "virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);

endclass

function void virtual_sequencer::build_phase(uvm_phase phase);

  super.build_phase(phase);

  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg)) begin
    `uvm_fatal("VIRTUAL_SEQUENCER", "Set the env_config properly")
  end

  s_seqr_h = new[e_cfg.no_of_source_agt];
  d_seqr_h = new[e_cfg.no_of_dest_agt];

endfunction : build_phase


