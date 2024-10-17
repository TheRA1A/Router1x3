//`timescale 1ns / 1ps

module router_top(

    input clk,resetn,
    input read_en_0,read_en_1,read_en_2,
    input pkt_valid,
    input [7:0]data_in,

    output [7:0]data_out_0,data_out_1,data_out_2,
    output valid_out_0,valid_out_1,valid_out_2,
    output err,busy
    );

    wire wire_soft_reset_0, wire_soft_reset_1, wire_soft_reset_2;
    wire [2:0]wire_write_en;
    wire [7:0]wire_register_data_out;
    wire wire_lfd_state;
    wire wire_empty_0,wire_empty_1,wire_empty_2;
    wire wire_full_0,wire_full_1,wire_full_2;
    wire wire_fifo_full;
    wire wire_parity_done;

    wire wire_detect_add;
    wire wire_write_en_reg;
    wire wire_low_pkt_valid;

    wire wire_ld_state,wire_full_state,wire_laf_state;
    wire wire_rst_int_reg;

    fifo fifo_0 (
        .clk(clk),
        .resetn(resetn),
        .soft_reset(wire_soft_reset_0),
        .read_en(read_en_0),
        .write_en(wire_write_en[0]),
        .lfd_state(wire_lfd_state),
        .data_in(wire_register_data_out),
        .data_out(data_out_0),
        .empty(wire_empty_0),
        .full(wire_full_0)
    );

    fifo fifo_1 (
        .clk(clk),
        .resetn(resetn),
        .soft_reset(wire_soft_reset_1),
        .read_en(read_en_1),
        .write_en(wire_write_en[1]),
        .lfd_state(wire_lfd_state),
        .data_in(wire_register_data_out),
        .data_out(data_out_1),
        .empty(wire_empty_1),
        .full(wire_full_1)
    );

    fifo fifo_2 (
        .clk(clk),
        .resetn(resetn),
        .soft_reset(wire_soft_reset_2),
        .read_en(read_en_2),
        .write_en(wire_write_en[2]),
        .lfd_state(wire_lfd_state),
        .data_in(wire_register_data_out),
        .data_out(data_out_2),
        .empty(wire_empty_2),
        .full(wire_full_2)
    );

    synchronizer sync (
        .clk(clk),
        .resetn(resetn),
        .read_en_0(read_en_0),
        .read_en_1(read_en_1),
        .read_en_2(read_en_2),
        .full_0(wire_full_0),
        .full_1(wire_full_1),
        .full_2(wire_full_2),
        .empty_0(wire_empty_0),
        .empty_1(wire_empty_1),
        .empty_2(wire_empty_2),
        .detect_add(wire_detect_add),
        .write_en_reg(wire_write_en_reg),
        .data_in(data_in[1:0]),
        .valid_out_0(valid_out_0),
        .valid_out_1(valid_out_1),
        .valid_out_2(valid_out_2),
        .soft_reset_0(wire_soft_reset_0),
        .soft_reset_1(wire_soft_reset_1),
        .soft_reset_2(wire_soft_reset_2),
        .fifo_full(wire_fifo_full),
        .write_en(wire_write_en)
    ); 

        fsm fsm_ (
            .clk(clk),
            .resetn(resetn),
            .pkt_valid(pkt_valid),
            .parity_done(wire_parity_done),
            .soft_reset_0(wire_soft_reset_0),
            .soft_reset_1(wire_soft_reset_1),
            .soft_reset_2(wire_soft_reset_2),
            .fifo_empty_0(wire_empty_0),
            .fifo_empty_1(wire_empty_1),
            .fifo_empty_2(wire_empty_2),
            .fifo_full(wire_fifo_full),
            .low_pkt_valid(wire_low_pkt_valid),
            .data_in(data_in[1:0]),
            .busy(busy),
            .detect_add(wire_detect_add),
            .lfd_state(wire_lfd_state),
            .ld_state(wire_ld_state),
            .laf_state(wire_laf_state),
            .full_state(wire_full_state),
            .write_en_reg(wire_write_en_reg),
            .rst_int_reg(wire_rst_int_reg)
        );

    register regi (
        .clk(clk),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .fifo_full(wire_fifo_full),
        .ld_state(wire_ld_state),
        .full_state(wire_full_state),
        .laf_state(wire_laf_state),
        .lfd_state(wire_lfd_state),
        .detect_add(wire_detect_add),
        .rst_int_reg(wire_rst_int_reg),
        .data_in(data_in),
        .parity_done(wire_parity_done),
        .low_pkt_valid(wire_low_pkt_valid),
        .err(err),
        .data_out(wire_register_data_out)
    );

endmodule
