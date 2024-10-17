class dest_config extends uvm_object;

  `uvm_object_utils(dest_config);

  virtual dest_if vif;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "dest_config");
    super.new(name);
  endfunction

endclass
