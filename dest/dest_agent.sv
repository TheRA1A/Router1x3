class dest_agent extends uvm_env;

  `uvm_component_utils(dest_agent);

  dest_config my_config;

  dest_drv drv_h;
  dest_mon mon_h;
  dest_sequencer seqr_h;

  function new(string name = "dest_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function void dest_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("DEST_AGENT", "This is build_phase", UVM_LOW)

  if (!uvm_config_db#(dest_config)::get(this, "", "dest_config", my_config)) begin
    `uvm_fatal("DEST_AGENT", "Set the dest_config properly")
  end

  mon_h = dest_mon::type_id::create("mon_h", this);

  if (my_config.is_active) begin
    drv_h  = dest_drv::type_id::create("drv_h", this);
    seqr_h = dest_sequencer::type_id::create("seqr_h", this);
  end

endfunction : build_phase


function void dest_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  `uvm_info("DEST_AGENT", "This is connect_phase", UVM_LOW)

  if (my_config.is_active) begin
    drv_h.seq_item_port.connect(seqr_h.seq_item_export);
  end

endfunction : connect_phase


