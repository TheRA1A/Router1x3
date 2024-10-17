//`timescale 1ns / 1ps

module synchronizer (
    input clk,
    resetn,
    read_en_0,
    read_en_1,
    read_en_2,
    full_0,
    full_1,
    full_2,
    empty_0,
    empty_1,
    empty_2,
    detect_add,
    write_en_reg,
    input [1:0] data_in,

    output valid_out_0,
    valid_out_1,
    valid_out_2,
    output reg soft_reset_0,
    output reg soft_reset_1,
    output reg soft_reset_2,
    output reg fifo_full,
    output reg [2:0] write_en
);

  reg [1:0] fifo_add;
  reg [4:0] count_fifo_0, count_fifo_1, count_fifo_2;
  reg [1:0] add;


  // Storing the fifo add

  always @(posedge clk) begin
    if (~resetn) fifo_add <= 0;
    else if (detect_add) fifo_add <= data_in;
  end

  // Write enable logic

  always @(posedge clk) begin
    if (~resetn) add <= 2'bxx;
    else if (detect_add) add <= data_in;
    else add <= add;
  end


  always @(*) begin
    if (write_en_reg) begin
      case (add)
        2'b00:   write_en = 3'b001;
        2'b01:   write_en = 3'b010;
        2'b10:   write_en = 3'b100;
        default: write_en = 3'b000;
      endcase
    end else write_en = 3'b0;
  end

  // Fifo full logic

  always @(*) begin
    case (fifo_add)
      2'b00:   fifo_full = full_0;
      2'b01:   fifo_full = full_1;
      2'b10:   fifo_full = full_2;
      default: fifo_full = 0;
    endcase
  end

  // Valid_out logic

  assign valid_out_0 = ~empty_0;
  assign valid_out_1 = ~empty_1;
  assign valid_out_2 = ~empty_2;

  // soft_reset_0 logic

  always @(posedge clk) begin

    if (~resetn) begin

      soft_reset_0 <= 1'b0;

      count_fifo_0 <= 5'b1;

    end else if (~valid_out_0) begin

      count_fifo_0 <= 5'b1;

    end else if (read_en_0) begin

      count_fifo_0 <= 5'b1;

    end else begin

      if (count_fifo_0 < 5'd30) begin

        soft_reset_0 <= 1'b0;

        count_fifo_0 <= count_fifo_0 + 1;

      end else begin

        soft_reset_0 <= 1'b1;

        count_fifo_0 <= 5'b1;

      end
    end
  end

  // soft_reset_1 logic

  always @(posedge clk) begin

    if (~resetn) begin

      soft_reset_1 <= 1'b0;

      count_fifo_1 <= 5'b1;

    end else if (~valid_out_1) begin

      count_fifo_1 <= 5'b1;

    end else if (read_en_1) begin

      count_fifo_1 <= 5'b1;

    end else begin

      if (count_fifo_1 < 5'd30) begin

        soft_reset_1 <= 1'b0;

        count_fifo_1 <= count_fifo_1 + 1;

      end else begin

        soft_reset_1 <= 1'b1;

        count_fifo_1 <= 5'b1;

      end
    end
  end
  // soft_reset_2 logic

  always @(posedge clk) begin

    if (~resetn) begin

      soft_reset_2 <= 1'b0;

      count_fifo_2 <= 5'b1;

    end else if (~valid_out_2) begin

      count_fifo_2 <= 5'b1;

    end else if (read_en_2) begin

      count_fifo_2 <= 5'b1;

    end else begin

      if (count_fifo_2 < 5'd30) begin

        soft_reset_2 <= 1'b0;

        count_fifo_2 <= count_fifo_2 + 1;

      end else begin

        soft_reset_2 <= 1'b1;

        count_fifo_2 <= 5'b1;

      end
    end
  end

endmodule
