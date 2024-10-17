interface dest_if (
    input bit clk
);

  // nets
  bit [7:0] data_out;
  bit valid_out;
  bit read_en;

  // clocking
  clocking drv_cb @(posedge clk);
    input valid_out;
    output read_en;
  endclocking : drv_cb

  clocking mon_cb @(posedge clk);
    input data_out;
    input valid_out;
    input read_en;
  endclocking : mon_cb

  // modports
  modport DRV_MP(clocking drv_cb);
  modport MON_MP(clocking mon_cb);

endinterface : dest_if
