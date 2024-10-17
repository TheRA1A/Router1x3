class source_agent extends uvm_env;

  `uvm_component_utils(source_agent);

  // env_config e_cfg;
  source_config my_config;

  source_drv drv_h;
  source_mon mon_h;
  source_sequencer seqr_h;

  function new(string name = "source_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function void source_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("SOURCE_AGENT", "This is build_phase", UVM_LOW)

  // if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg)) begin
  //   `uvm_fatal("SOURCE_AGENT", "Set the source_config properly")
  // end

  // my_config = e_cfg.s_cfg;

  if (!uvm_config_db#(source_config)::get(this, "", "source_config", my_config)) begin
    `uvm_fatal("source_agent", "Set the source_config properly")
  end

  mon_h = source_mon::type_id::create("mon_h", this);

  if (my_config.is_active) begin
    drv_h  = source_drv::type_id::create("drv_h", this);
    seqr_h = source_sequencer::type_id::create("seqr_h", this);
  end

endfunction : build_phase


function void source_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  `uvm_info("SOURCE_AGENT", "This is connect_phase", UVM_LOW)

  if (my_config.is_active) begin
    drv_h.seq_item_port.connect(seqr_h.seq_item_export);
  end

endfunction : connect_phase





