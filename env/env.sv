class env extends uvm_env;

  `uvm_component_utils(env);

  env_config my_config;

  source_agent_top s_agt_top_h;
  dest_agent_top d_agt_top_h;

  virtual_sequencer v_seqr_h;

  scoreboard sb;

  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function void env::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("ENV", "This is build_phase", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(this, "", "env_config", my_config)) begin
    `uvm_fatal("env", "Set the env_config properly")
  end

  s_agt_top_h = source_agent_top::type_id::create("s_agt_top_h", this);
  d_agt_top_h = dest_agent_top::type_id::create("d_agt_top_h", this);

  v_seqr_h = virtual_sequencer::type_id::create("v_seqr_h", this);

  sb = scoreboard::type_id::create("sb", this);

endfunction : build_phase


function void env::connect_phase(uvm_phase phase);

  super.connect_phase(phase);

  `uvm_info("ENV", "This is connect_phase", UVM_LOW)

  for (int i = 0; i < my_config.no_of_source_agt; i++) begin
    v_seqr_h.s_seqr_h[i] = s_agt_top_h.agt_h[i].seqr_h;
  end

  for (int i = 0; i < my_config.no_of_dest_agt; i++) begin
    v_seqr_h.d_seqr_h[i] = d_agt_top_h.agt_h[i].seqr_h;
  end

  foreach (my_config.s_cfg[i]) begin
    s_agt_top_h.agt_h[i].mon_h.source_port.connect(sb.source_fifo.analysis_export);
  end

  foreach (my_config.d_cfg[i]) begin
    d_agt_top_h.agt_h[i].mon_h.dest_port.connect(sb.dest_fifo[i].analysis_export);
  end

endfunction : connect_phase

