class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  source_config s_cfg[];
  dest_config d_cfg[];
  env_config e_cfg;

  bit [1:0] add;  /// |This for setting both side same address

  bit has_source_agent = 1;
  bit has_dest_agent = 1;

  int no_of_dest_agt = 3;
  int no_of_source_agt = 1;

  env env_h;

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern function void router_config();

endclass

function void base_test::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  uvm_top.print_topology();
endfunction : end_of_elaboration_phase

function void base_test::router_config();

  `uvm_info("BASE_TEST", "This is a router_config", UVM_LOW)

  // Set the source_config

  if (has_source_agent) begin

    s_cfg = new[no_of_source_agt];

    foreach (s_cfg[i]) begin

      s_cfg[i] = source_config::type_id::create("s_cfg[i]");

      if (!uvm_config_db#(virtual source_if)::get(this, "", "in", s_cfg[i].vif)) begin
        `uvm_fatal("BASE_TEST", "Set the the source interface properly")
      end

      s_cfg[i].is_active = UVM_ACTIVE;
      e_cfg.s_cfg[i] = s_cfg[i];

    end

  end

  // Set the dest_config

  if (has_dest_agent) begin

    d_cfg = new[no_of_dest_agt];

    foreach (d_cfg[i]) begin

      d_cfg[i] = dest_config::type_id::create($sformatf("d_cfg[%0d]", i));

      if (!uvm_config_db#(virtual dest_if)::get(
              this, "", $sformatf("in%0d", i), d_cfg[i].vif
          )) begin
        `uvm_fatal("BASE_TEST", "Set the destination interface properly")
      end

      d_cfg[i].is_active = UVM_ACTIVE;
      e_cfg.d_cfg[i] = d_cfg[i];

    end

  end

endfunction : router_config

function void base_test::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("BASE_TEST", "This is a build_phase", UVM_LOW)

  e_cfg = env_config::type_id::create("e_cfg");

  if (has_source_agent) begin
    e_cfg.s_cfg = new[no_of_source_agt];
  end

  if (has_source_agent) begin
    e_cfg.d_cfg = new[no_of_dest_agt];
  end

  router_config();

  e_cfg.has_source_agent = has_source_agent;
  e_cfg.has_dest_agent   = has_dest_agent;
  e_cfg.no_of_dest_agt   = no_of_dest_agt;
  e_cfg.no_of_source_agt = no_of_source_agt;

  // Set the env_config
  uvm_config_db#(env_config)::set(this, "*", "env_config", e_cfg);

  // Set the same address at both side (source and destination)
  add = $urandom % 3;
  // add = 2;
  uvm_config_db#(bit [1:0])::set(this, "*", "bit", add);

  env_h = env::type_id::create("env_h", this);

endfunction : build_phase


class short_test extends base_test;

  `uvm_component_utils(short_test)

  // short_seqs s_seqs_h;
  // less_delay_seqs d_seqs_h;

  short_virtual_seqs v_seqs_h;

  // bit [1:0] add;

  function new(string name = "short_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass

function void short_test::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("SHORT_TEST", "This is build_phase", UVM_LOW)

endfunction : build_phase

task short_test::run_phase(uvm_phase phase);

  super.run_phase(phase);

  phase.raise_objection(this);

  `uvm_info("SHORT_TEST", "This is before start", UVM_LOW)

  // s_seqs_h = short_seqs::type_id::create("s_seqs_h");
  // d_seqs_h = less_delay_seqs::type_id::create("d_seqs_h");

  // fork
  //   s_seqs_h.start(env_h.s_agt_top_h.agt_h[0].seqr_h);
  //   d_seqs_h.start(env_h.d_agt_top_h.agt_h[super.add].seqr_h);
  // join

  v_seqs_h = short_virtual_seqs::type_id::create("v_seqs_h");

  v_seqs_h.start(env_h.v_seqr_h);

  `uvm_info("SHORT_TEST", "This is after the start", UVM_LOW)

  phase.drop_objection(this);

endtask : run_phase


class medium_test extends base_test;

  `uvm_component_utils(medium_test)

  // medium_seqs s_seqs_h;
  // medium_delay_seqs d_seqs_h;

  medium_virtual_seqs v_seqs_h;

  function new(string name = "medium_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  extern task run_phase(uvm_phase phase);

endclass

task medium_test::run_phase(uvm_phase phase);

  super.run_phase(phase);

  phase.raise_objection(this);

  `uvm_info("MEDIUM_TEST", "This is before start", UVM_LOW)

  // s_seqs_h = medium_seqs::type_id::create("s_seqs_h");
  // d_seqs_h = medium_delay_seqs::type_id::create("d_seqs_h");

  // fork
  //   s_seqs_h.start(env_h.s_agt_top_h.agt_h[0].seqr_h);
  //   d_seqs_h.start(env_h.d_agt_top_h.agt_h[super.add].seqr_h);
  // join

  v_seqs_h = medium_virtual_seqs::type_id::create("v_seqs_h");

  v_seqs_h.start(env_h.v_seqr_h);

  `uvm_info("MEDIUM_TEST", "This is after the start", UVM_LOW)

  phase.drop_objection(this);

endtask : run_phase


class large_test extends base_test;

  `uvm_component_utils(large_test)

  large_seqs s_seqs_h;
  large_delay_seqs d_seqs_h;
  large_virtual_seqs v_seqs_h;

  function new(string name = "large_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  extern task run_phase(uvm_phase phase);

endclass

task large_test::run_phase(uvm_phase phase);

  super.run_phase(phase);

  phase.raise_objection(this);

  // s_seqs_h = large_seqs::type_id::create("s_seqs_h");
  // d_seqs_h = large_delay_seqs::type_id::create("d_seqs_h");

  // fork
  //   s_seqs_h.start(env_h.s_agt_top_h.agt_h[0].seqr_h);
  //   d_seqs_h.start(env_h.d_agt_top_h.agt_h[super.add].seqr_h);
  // join

  v_seqs_h = large_virtual_seqs::type_id::create("v_seqs_h");

  v_seqs_h.start(env_h.v_seqr_h);

  `uvm_info("LARGE_TEST", "This is run_phase in large_test", UVM_LOW)

  phase.drop_objection(this);

endtask : run_phase



class large_less extends base_test;

  `uvm_component_utils(large_less)

  large_seqs s_seqs_h;
  large_delay_seqs d_seqs_h;
  large_less_virtual v_seqs_h;

  function new(string name = "large_less", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  extern task run_phase(uvm_phase phase);

endclass

task large_less::run_phase(uvm_phase phase);

  super.run_phase(phase);

  phase.raise_objection(this);

  // s_seqs_h = large_seqs::type_id::create("s_seqs_h");
  // d_seqs_h = large_delay_seqs::type_id::create("d_seqs_h");

  // fork
  //   s_seqs_h.start(env_h.s_agt_top_h.agt_h[0].seqr_h);
  //   d_seqs_h.start(env_h.d_agt_top_h.agt_h[super.add].seqr_h);
  // join

  v_seqs_h = large_less_virtual::type_id::create("v_seqs_h");

  v_seqs_h.start(env_h.v_seqr_h);

  `uvm_info("large_less", "This is run_phase in large_less", UVM_LOW)

  phase.drop_objection(this);

endtask : run_phase


