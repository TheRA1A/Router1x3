class source_trans extends uvm_sequence_item;

  `uvm_object_utils(source_trans);


  bit resetn, pkt_valid, err, busy;

  rand bit [7:0] header;
  rand bit [7:0] payload[];
  bit [7:0] parity;


  constraint source_c {
    header[1:0] != 2'b11;
    payload.size == header[7:2];
    header[7:2] != 0;
  }

  function new(string name = "source_trans");
    super.new(name);
  endfunction

  function void post_randomize();
    parity = header;
    foreach (payload[i]) begin
      parity = parity ^ payload[i];
    end
  endfunction : post_randomize

  function void do_print(uvm_printer printer);
    /*  chain the print with parent classes  */
    super.do_print(printer);

    /*  list of local properties to be printed:  */

    printer.print_field("resetn", this.resetn, 1, UVM_BIN);
    printer.print_field("pkt_valid", this.pkt_valid, 1, UVM_BIN);
    printer.print_field("err", this.err, 1, UVM_BIN);
    printer.print_field("busy", this.busy, 1, UVM_BIN);
    printer.print_field("header", this.header, 8, UVM_BIN);
    printer.print_field("address", this.header[1:0], 2, UVM_BIN);
    printer.print_field("payload_length", this.header[7:2], 6, UVM_DEC);
    foreach (payload[i]) begin
      printer.print_field($sformatf("payload[%0d]", i), this.payload[i], 8, UVM_DEC);
    end
    printer.print_field("parity", this.parity, 8, UVM_DEC);
  endfunction : do_print

endclass



