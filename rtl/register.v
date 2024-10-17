//`timescale 1ns / 1ps

module register (
    input clk,
    resetn,
    input pkt_valid,
    input fifo_full,
    input ld_state,
    full_state,
    laf_state,
    lfd_state,
    detect_add,
    rst_int_reg,
    input [7:0] data_in,

    output reg parity_done,
    output reg low_pkt_valid,
    output reg err,
    output reg [7:0] data_out
);

  reg [7:0] fifo_full_state_byte, header_byte, internal_parity, packet_parity;


  // Parity done

  always @(posedge clk) begin
    if (~resetn || detect_add) parity_done <= 1'b0;
    else if ((ld_state && ~fifo_full && ~pkt_valid) || (laf_state && low_pkt_valid && ~parity_done))
      parity_done <= 1'b1;
    else parity_done <= parity_done;
  end


  // Low pkt valid 

  always @(posedge clk) begin
    if (~resetn || rst_int_reg) low_pkt_valid <= 1'b0;
    else if (ld_state && ~pkt_valid) low_pkt_valid <= 1'b1;
    else low_pkt_valid <= low_pkt_valid;
  end


  // Data_out

  always @(posedge clk) begin
    if (~resetn) begin
      data_out <= 8'b0;
      header_byte <= 8'b0;
      fifo_full_state_byte <= 8'b0;
    end else if (detect_add && pkt_valid) header_byte <= data_in;
    else if (lfd_state) data_out <= header_byte;
    else if (ld_state && ~fifo_full) data_out <= data_in;
    else if (fifo_full && ld_state) fifo_full_state_byte <= data_in;
    else if (laf_state) data_out <= fifo_full_state_byte;
    else data_out <= data_out;
  end


  // Internal parity block

  always @(posedge clk) begin
    if (~resetn || detect_add) internal_parity <= 8'b0;
    else if (lfd_state && pkt_valid) internal_parity <= internal_parity ^ header_byte;
    else if (pkt_valid && ld_state && ~full_state) internal_parity <= internal_parity ^ data_in;
    else internal_parity <= internal_parity;
  end


  // Packet parity

  always @(posedge clk) begin
    if (~resetn || detect_add) packet_parity <= 8'b0;
    else if ((ld_state && ~fifo_full && ~pkt_valid) || (laf_state && low_pkt_valid && ~parity_done))
      packet_parity <= data_in;
    else packet_parity <= packet_parity;
  end


  //  err

  always @(posedge clk) begin
    if (~resetn) err <= 1'b0;
    else if (parity_done) begin
      if (internal_parity == packet_parity) err <= 1'b0;
      else err <= 1'b1;
    end else err <= err;
  end

endmodule
