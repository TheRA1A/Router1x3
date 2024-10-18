class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard);

  uvm_tlm_analysis_fifo #(source_trans) source_fifo;
  uvm_tlm_analysis_fifo #(dest_trans) dest_fifo[];

  source_trans source_data;
  dest_trans dest_data;

  source_trans source_cov;
  dest_trans dest_cov;

  env_config e_cfg;

  covergroup source_cov_group;

    ADDR: coverpoint source_cov.header[1:0] {
      // bins addr0 = {2'b00}; bins addr1 = {2'b01}; bins addr2 = {2'b01};
      bins addr0 = {0};
      bins addr1 = {1};
      bins addr2 = {2};
    }

    PAYLOAD_LENGTH: coverpoint source_cov.header[7:2] {
      bins small_packet = {[1 : 14]};
      bins mid_packet = {[21 : 40]};
      bins large_packet = {[41 : 63]};
    }

    ERROR: coverpoint source_cov.err {bins error = {1'b1}; bins no_error = {1'b0};}

  endgroup

  covergroup dest_cov_group;

    ADDR: coverpoint dest_cov.header[1:0] {
      // bins addr0 = {2'b00}; bins addr1 = {2'b01}; bins addr2 = {2'b01};
      bins addr0 = {0};
      bins addr1 = {1};
      bins addr2 = {2};
    }

    PAYLOAD_LENGTH: coverpoint dest_cov.header[7:2] {
      bins small_packet = {[1 : 14]};
      bins mid_packet = {[21 : 40]};
      bins large_packet = {[41 : 63]};
    }

  endgroup

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    source_cov_group = new();
    dest_cov_group   = new();
  endfunction


  extern function void build_phase(uvm_phase phase);
  // extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task compare(source_trans s_trans, dest_trans d_trans);

endclass


function void scoreboard::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("SCOREBOARD", "This is build_phase", UVM_LOW)


  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg)) begin
    `uvm_fatal("SCOREBOARD", "Set the env_config properly")
  end

  source_data = source_trans::type_id::create("source_data");
  dest_data   = dest_trans::type_id::create("dest_data");

  source_fifo = new("source_fifo", this);
  dest_fifo   = new[e_cfg.no_of_dest_agt];

  foreach (dest_fifo[i]) begin
    dest_fifo[i] = new($sformatf("dest_fifo[%0d]", i), this);
  end

endfunction : build_phase



task scoreboard::run_phase(uvm_phase phase);

  `uvm_info("SCOREBOARD", "This is run_phase", UVM_LOW)

  forever begin
    fork

      // For Source
      begin
        source_fifo.get(source_data);
        source_data.print();
        source_cov = source_data;
        source_cov_group.sample();
      end

      // For Destination
      begin
        fork
          begin
            dest_fifo[0].get(dest_data);
            dest_data.print();
            dest_cov = dest_data;
            dest_cov_group.sample();
          end
          begin
            dest_fifo[1].get(dest_data);
            dest_data.print();
            dest_cov = dest_data;
            dest_cov_group.sample();
          end
          begin
            dest_fifo[2].get(dest_data);
            dest_data.print();
            dest_cov = dest_data;
            dest_cov_group.sample();
          end
        join_any
        disable fork;
      end
    join
    compare(source_data, dest_data);
  end

endtask : run_phase

task scoreboard::compare(source_trans s_trans, dest_trans d_trans);

  if (s_trans.header == d_trans.header) begin
    `uvm_info("SCOREBOARD", "Header is matched", UVM_LOW)
  end else begin
    `uvm_error("SCOREBOARD", "Header is not matched")
  end

  if (s_trans.payload == d_trans.payload) begin
    `uvm_info("SCOREBOARD", "Payload is matched", UVM_LOW)
  end else begin
    `uvm_error("SCOREBOARD", "Payload is not matched")
  end

  if (s_trans.parity == d_trans.parity) begin
    `uvm_info("SCOREBOARD", "Parity is matched", UVM_LOW)
  end else begin
    `uvm_error("SCOREBOARD", "Parity is not matched")
  end

endtask : compare


