class source_agent_top extends uvm_env;

  `uvm_component_utils(source_agent_top);

  source_agent agt_h [];
  env_config   e_cfg;

  function new(string name = "source_agent_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass


function void source_agent_top::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("SOURCE_AGENT_TOP", "This is build_phase", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg)) begin
    `uvm_fatal("SOURCE_AGENT_TOP", "Set the env_config properly")
  end

  agt_h = new[e_cfg.no_of_source_agt];

  foreach (agt_h[i]) begin
    agt_h[i] = source_agent::type_id::create($sformatf("agt_h[%0d]", i), this);
    uvm_config_db#(source_config)::set(this, $sformatf("agt_h[%0d]*", i), "source_config",
                                       e_cfg.s_cfg[i]);
  end

endfunction : build_phase

task source_agent_top::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info("SOURCE_AGENT_TOP", "This is run_phase", UVM_LOW)
  // uvm_top.print_topology();
endtask : run_phase

