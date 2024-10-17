class source_mon extends uvm_monitor;

  `uvm_component_utils(source_mon);

  virtual source_if.MON_MP vif;
  env_config env_c;
  source_config my_config;

  uvm_analysis_port #(source_trans) source_port;

  function new(string name = "source_mon", uvm_component parent);
    super.new(name, parent);
    source_port = new("source_port", this);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_data();

endclass


function void source_mon::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("SOURCE_MON", "This is build_phase", UVM_LOW)

  // if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_c)) begin
  //   `uvm_fatal("SOURCE_MON", "Set the env_config properly")
  // end
  // my_config = env_c.s_cfg;

  if (!uvm_config_db#(source_config)::get(this, "", "source_config", my_config)) begin
    `uvm_fatal("SOURCE_MON", "Set the source_config properly")
  end


endfunction : build_phase

function void source_mon::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  vif = my_config.vif;
endfunction : connect_phase


task source_mon::run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin
    collect_data();
  end
endtask : run_phase


task source_mon::collect_data();

  source_trans data_sent;
  data_sent = source_trans::type_id::create("data_sent");

  wait (~vif.mon_cb.busy);
  wait (vif.mon_cb.pkt_valid);

  data_sent.header  = vif.mon_cb.data_in;
  data_sent.payload = new[data_sent.header[7:2]];

  @(vif.mon_cb);

  foreach (data_sent.payload[i]) begin
    wait (~vif.mon_cb.busy);
    data_sent.payload[i] = vif.mon_cb.data_in;
    @(vif.mon_cb);
  end

  // Here pkt_valid goes to zero
  data_sent.parity = vif.mon_cb.data_in;

  repeat (2) @(vif.mon_cb);

  data_sent.busy = vif.mon_cb.busy;
  data_sent.err  = vif.mon_cb.err;

  `uvm_info("SOURCE_MON", $sformatf("printing from monitor \n %s", data_sent.sprint()), UVM_LOW)

  source_port.write(data_sent);

endtask




