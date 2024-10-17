class dest_mon extends uvm_monitor;

  `uvm_component_utils(dest_mon);

  virtual dest_if.MON_MP vif;
  dest_config my_config;

  uvm_analysis_port #(dest_trans) dest_port;

  function new(string name = "dest_mon", uvm_component parent);
    super.new(name, parent);
    dest_port = new("dest_port", this);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_data();

endclass

function void dest_mon::build_phase(uvm_phase phase);

  `uvm_info("DEST_MON", "This is build_phase", UVM_LOW)

  super.build_phase(phase);

  if (!uvm_config_db#(dest_config)::get(this, "", "dest_config", my_config)) begin
    `uvm_fatal("DEST_MON", "Set the dest_config properly")
  end

endfunction : build_phase

function void dest_mon::connect_phase(uvm_phase phase);

  `uvm_info("DEST_MON", "This is connect_phase", UVM_LOW)

  super.connect_phase(phase);
  vif = my_config.vif;

endfunction : connect_phase


task dest_mon::run_phase(uvm_phase phase);

  `uvm_info("DEST_MON", "This is run_phase", UVM_LOW)

  super.run_phase(phase);

  forever begin
    collect_data();
  end

endtask : run_phase


task dest_mon::collect_data();

  dest_trans data_sent;
  data_sent = dest_trans::type_id::create("data_sent");

  wait (vif.mon_cb.read_en);

  @(vif.mon_cb);

  data_sent.header  = vif.mon_cb.data_out;
  data_sent.payload = new[data_sent.header[7:2]];

  @(vif.mon_cb);

  foreach (data_sent.payload[i]) begin
    data_sent.payload[i] = vif.mon_cb.data_out;
    @(vif.mon_cb);
  end

  data_sent.parity = vif.mon_cb.data_out;
  @(vif.mon_cb);

  `uvm_info("DEST_MON", $sformatf("printing from monitor \n %s", data_sent.sprint()), UVM_LOW)

  dest_port.write(data_sent);


endtask : collect_data



















