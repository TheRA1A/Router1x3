module top ();

  import uvm_pkg::*;
  import router_pkg::*;

  bit clk;

  always #5 clk = ~clk;

  source_if in (clk);
  dest_if in0 (clk);
  dest_if in1 (clk);
  dest_if in2 (clk);

  router_top duv (

      .clk(clk),
      .resetn(in.resetn),

      // Connected to the source interface
      .pkt_valid(in.pkt_valid),
      .data_in(in.data_in),
      .err(in.err),
      .busy(in.busy),

      // Connected to the destination interface 0
      .read_en_0  (in0.read_en),
      .valid_out_0(in0.valid_out),
      .data_out_0 (in0.data_out),

      // Connected to the destination interface 1
      .read_en_1  (in1.read_en),
      .valid_out_1(in1.valid_out),
      .data_out_1 (in1.data_out),

      // Connected to the destination interface 2
      .read_en_2  (in2.read_en),
      .valid_out_2(in2.valid_out),
      .data_out_2 (in2.data_out)

  );

  initial begin

    uvm_config_db#(virtual source_if)::set(null, "*", "in", in);

    uvm_config_db#(virtual dest_if)::set(null, "*", "in0", in0);
    uvm_config_db#(virtual dest_if)::set(null, "*", "in1", in1);
    uvm_config_db#(virtual dest_if)::set(null, "*", "in2", in2);

    run_test();  // NOTE: +UVM_TESTNAME="test class name"

  end

  property stable_data;
    @(posedge clk) in.busy |=> $stable(
        in.data_in
    );
  endproperty : stable_data

  property busy_check;
    @(posedge clk) $rose(
        in.pkt_valid
    ) |=> in.busy;
  endproperty : busy_check

  property valid_signal;
    @(posedge clk) $rose(
        in.pkt_valid
    ) |-> ##3 (in0.valid_out | in1.valid_out | in2.valid_out);
  endproperty : valid_signal

  property rd_en0;
    @(posedge clk) in0.valid_out |-> ##[1:29] in0.read_en;
  endproperty : rd_en0

  property rd_en1;
    @(posedge clk) in1.valid_out |-> ##[1:29] in1.read_en;
  endproperty : rd_en1

  property rd_en2;
    @(posedge clk) in2.valid_out |-> ##[1:29] in2.read_en;
  endproperty : rd_en2

  property read_en_low0;
    @(posedge clk) $fell(
        in0.valid_out
    ) |=> $fell(
        in0.read_en
    );
  endproperty : read_en_low0

  property read_en_low1;
    @(posedge clk) $fell(
        in1.valid_out
    ) |=> $fell(
        in1.read_en
    );
  endproperty : read_en_low1

  property read_en_low2;
    @(posedge clk) $fell(
        in2.valid_out
    ) |=> $fell(
        in2.read_en
    );
  endproperty : read_en_low2

  SD :
  assert property (stable_data) begin
    $display("stable_data assertion pass");
  end else begin
    $display("stable_data assertion fail");
  end

  BC :
  assert property (busy_check) begin
    $display("busy_check assertion pass");
  end else begin
    $display("busy_check assertion fail");
  end

  VS :
  assert property (valid_signal) begin
    $display("valid_signal assertion pass");
  end else begin
    $display("valid_signal assertion fail");
  end

  RE0 :
  assert property (rd_en0) begin
    $display("rd_en0 assertion pass");
  end else begin
    $display("rd_en0 assertion fail");
  end

  RE1 :
  assert property (rd_en1) begin
    $display("rd_en1 assertion pass");
  end else begin
    $display("rd_en1 assertion fail");
  end

  RE2 :
  assert property (rd_en2) begin
    $display("rd_en2 assertion pass");
  end else begin
    $display("rd_en2 assertion fail");
  end

  REL0 :
  assert property (read_en_low0) begin
    $display("read_en_low0 assertion pass");
  end else begin
    $display("read_en_low0 assertion fail");
  end

  REL1 :
  assert property (read_en_low1) begin
    $display("read_en_low1 assertion pass");
  end else begin
    $display("read_en_low1 assertion fail");
  end

  REL2 :
  assert property (read_en_low2) begin
    $display("read_en_low2 assertion pass");
  end else begin
    $display("read_en_low2 assertion fail");
  end

  C1 :
  cover property (stable_data);
  C2 :
  cover property (busy_check);
  C3 :
  cover property (valid_signal);
  C4 :
  cover property (rd_en0);
  C5 :
  cover property (rd_en1);
  C6 :
  cover property (rd_en2);
  C7 :
  cover property (read_en_low0);
  C8 :
  cover property (read_en_low1);
  C9 :
  cover property (read_en_low2);

endmodule

