class dest_trans extends uvm_sequence_item;

  `uvm_object_utils(dest_trans);


  bit [7:0] header, payload[], parity;
  bit read_en, valid_out;

  rand bit [5:0] delay;


  function new(string name = "dest_trans");
    super.new(name);
  endfunction

  extern function void do_print(uvm_printer printer);

endclass

function void dest_trans::do_print(uvm_printer printer);

  super.do_print(printer);

  printer.print_field("read_en", this.read_en, 1, UVM_BIN);
  printer.print_field("valid_out", this.valid_out, 1, UVM_BIN);
  printer.print_field("delay", this.delay, 6, UVM_DEC);
  printer.print_field("header", this.header, 8, UVM_BIN);
  printer.print_field("address", this.header[1:0], 2, UVM_BIN);
  printer.print_field("payload_length", this.header[7:2], 6, UVM_DEC);
  foreach (payload[i]) begin
    printer.print_field($sformatf("payload[%0d]", i), this.payload[i], 8, UVM_DEC);
  end
  printer.print_field("parity", this.parity, 8, UVM_DEC);

endfunction



