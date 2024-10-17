class env_config extends uvm_object;

  `uvm_object_utils(env_config);

  bit has_source_agent = 1;
  bit has_dest_agent = 1;

  source_config s_cfg[];
  dest_config d_cfg[];

  int no_of_dest_agt = 3;
  int no_of_source_agt = 1;

  function new(string name = "env_config");
    super.new(name);
  endfunction

endclass


