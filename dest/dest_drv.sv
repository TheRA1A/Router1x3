class dest_drv extends uvm_driver #(dest_trans);

  `uvm_component_utils(dest_drv);

  virtual dest_if.DRV_MP vif;
  dest_config my_config;

  function new(string name = "dest_drv", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task send_to_dut(dest_trans trans);

endclass

function void dest_drv::build_phase(uvm_phase phase);

  `uvm_info("DEST_DRV", "This is build_phase", UVM_LOW)

  super.build_phase(phase);

  if (!uvm_config_db#(dest_config)::get(this, "", "dest_config", my_config)) begin
    `uvm_fatal("DEST_DRV", "Set the dest_config properly")
  end

endfunction : build_phase

function void dest_drv::connect_phase(uvm_phase phase);

  `uvm_info("DEST_DRV", "This is connect_phase", UVM_LOW)

  super.connect_phase(phase);
  vif = my_config.vif;

endfunction : connect_phase

task dest_drv::run_phase(uvm_phase phase);

  `uvm_info("DEST_DRV", "This is run_phase", UVM_LOW)

  super.run_phase(phase);

  forever begin

    `uvm_info("DEST_DRV", "get_next_item is asserted", UVM_LOW)
    seq_item_port.get_next_item(req);
    `uvm_info("DEST_DRV", "get_next_item is unblocked", UVM_LOW)
    send_to_dut(req);
    seq_item_port.item_done();
    `uvm_info("DEST_DRV", "item_done is asserted", UVM_LOW)
  end

endtask : run_phase


task dest_drv::send_to_dut(dest_trans trans);

  `uvm_info("DEST_DRV", "This is send_to_dut", UVM_LOW)
  `uvm_info("DEST_DRV", $sformatf("printing from driver \n %s", trans.sprint()), UVM_LOW)

  @(vif.drv_cb);

  `uvm_info("DEST_DRV", "This is before the capture of valid_out", UVM_LOW)

  wait (vif.drv_cb.valid_out);

  `uvm_info("DEST_DRV", "This is after the capture of valid_out", UVM_LOW)

  // TODO: ADD Delay

  repeat (trans.delay) @(vif.drv_cb);  // Randome delay
  // repeat (5) @(vif.drv_cb);  // Randome delay

  `uvm_info("DEST_DRV", "This is before driving the read_en", UVM_LOW)
  vif.drv_cb.read_en <= 1'b1;
  `uvm_info("DEST_DRV", "This is after driving the read_en", UVM_LOW)

  // @(vif.drv_cb);

  wait (~vif.drv_cb.valid_out);

  // @(vif.drv_cb);
  vif.drv_cb.read_en <= 1'b0;
  @(vif.drv_cb);

endtask















