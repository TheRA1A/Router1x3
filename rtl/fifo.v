// NOTE: PACKET = HEADER + PAYLOAD + PARITY 
//      
//      HEADER[7:0] = PARITY[7] + PAYLOAD_LENGTH [6:2] + ADD[1:0]
//      
//      PAYLOAD = DATA
//      
//      PARITY = PARITY BYTE

//`timescale 1ns / 1ps

module fifo (
    input clk,
    resetn,
    soft_reset,
    input read_en,
    write_en,
    input lfd_state,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output empty,
    full
);

  reg [8:0] mem[15:0];
  reg [4:0] read_ptr, write_ptr;
  reg delay_lfd;
  reg [6:0] count;

  // Logic for Delayed lfd_state

  always @(posedge clk) begin
    if (~resetn || soft_reset) delay_lfd <= 1'b0;
    else delay_lfd <= lfd_state;
  end

  // Logic for write and read ptr

  always @(posedge clk) begin
    if (~resetn || soft_reset) begin
      read_ptr  <= 5'b0;
      write_ptr <= 5'b0;
    end else begin
      if (read_en && ~empty) read_ptr <= read_ptr + 5'b1;
      else read_ptr <= read_ptr;

      if (write_en && ~full) write_ptr <= write_ptr + 5'b1;
      else write_ptr <= write_ptr;
    end
  end

  // logic for write

  integer i;

  always @(posedge clk) begin
    if (~resetn || soft_reset) begin
      for (i = 0; i < 16; i = i + 1) begin
        mem[i] <= 0;
      end
    end else if (write_en && ~full) begin
      mem[write_ptr[3:0]] <= {delay_lfd, data_in};
    end
  end

  // logic for read
  wire flag1;
  assign flag1 = ((count == 0) && (data_out != 0)) ? 1'b1 : 1'b0;

  always @(posedge clk) begin
    if (~resetn) data_out <= 8'b0;
    else if (soft_reset) data_out <= 8'bz;
    else if (flag1) data_out <= 8'bz;
    else if (read_en && ~empty) data_out <= mem[read_ptr[3:0]][7:0];
  end

  // Logic for counter
  wire flag0;
  assign flag0 = (mem[read_ptr[3:0]][8] == 1'b1);

  always @(posedge clk) begin
    if (~resetn || soft_reset) count <= 7'b0;
    else if (read_en && ~empty) begin
      if (flag0) begin
        count <= mem[read_ptr[3:0]][7:2] + 7'b1;  // NOTE: TOTEL DATA LENGTH = PAYLOAD + PARWTY
      end else if (count != 0) begin
        count <= count - 1'b1;
      end
    end else begin
      count <= count;
    end
  end

  // Empty and Full Logic

  assign empty = (read_ptr == write_ptr);
  assign full  = (read_ptr == {~write_ptr[4], write_ptr[3:0]});



endmodule
