class source_drv extends uvm_driver #(source_trans);

  `uvm_component_utils(source_drv);

  virtual source_if.DRV_MP vif;
  // env_config env_c;
  source_config my_config;

  function new(string name = "source_drv", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task send_to_dut(source_trans trans);

endclass

function void source_drv::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("SOURCE_DRV", "This is build_phase", UVM_LOW)

  // if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_c)) begin
  //   `uvm_fatal("SOURCE_DRV", "Set the source_config properly")
  // end
  // my_config = env_c.s_cfg;


  if (!uvm_config_db#(source_config)::get(this, "", "source_config", my_config)) begin
    `uvm_fatal("SOURCE_DRV", "Set the source_config properly")
  end

endfunction : build_phase

function void source_drv::connect_phase(uvm_phase phase);

  `uvm_info("SOURCE_DRV", "This is connect_phase", UVM_LOW)

  super.connect_phase(phase);
  vif = my_config.vif;
endfunction : connect_phase

task source_drv::send_to_dut(source_trans trans);

  `uvm_info("SOURCE_DRV", "This is send_to_dut", UVM_LOW)
  `uvm_info("SOURCE_DRV", $sformatf("printing from driver \n %s", trans.sprint()), UVM_LOW)

  wait (vif.drv_cb.busy == 0);
  vif.drv_cb.pkt_valid <= 1'b1;

  vif.drv_cb.data_in   <= trans.header;

  @(vif.drv_cb);

  foreach (trans.payload[i]) begin
    wait (vif.drv_cb.busy == 0);
    vif.drv_cb.data_in <= trans.payload[i];
    @(vif.drv_cb);
  end

  vif.drv_cb.pkt_valid <= 1'b0;

  vif.drv_cb.data_in   <= trans.parity;

  repeat (2) @(vif.drv_cb);

  `uvm_info("SOURCE_DRV", "This is end of send_to_dut", UVM_LOW)


endtask : send_to_dut

task source_drv::run_phase(uvm_phase phase);

  `uvm_info("SOURCE_DRV", "This is run_phase", UVM_LOW)

  @(vif.drv_cb);
  vif.drv_cb.resetn <= 1'b0;

  repeat (2) @(vif.drv_cb);
  vif.drv_cb.resetn <= 1'b1;

  forever begin
    `uvm_info("SOURCE_DRV", "get_next_item is asserted", UVM_LOW)
    seq_item_port.get_next_item(req);
    `uvm_info("SOURCE_DRV", "get_next_item is unblocked", UVM_LOW)
    send_to_dut(req);
    seq_item_port.item_done();
    `uvm_info("SOURCE_DRV", "item_done is asserted", UVM_LOW)
  end

endtask : run_phase



