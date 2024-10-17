//`timescale 1ns / 1ps

interface source_if (
    input bit clk
);

  // nets
  bit resetn;
  bit pkt_valid;
  bit [7:0] data_in;
  bit err;
  bit busy;

  // clocking
  clocking drv_cb @(posedge clk);
    output resetn;
    output pkt_valid;
    output data_in;
    input busy;
  endclocking : drv_cb

  clocking mon_cb @(posedge clk);
    input err;
    input resetn;
    input pkt_valid;
    input data_in;
    input busy;
  endclocking : mon_cb

  // modports
  modport DRV_MP(clocking drv_cb);
  modport MON_MP(clocking mon_cb);

endinterface : source_if

