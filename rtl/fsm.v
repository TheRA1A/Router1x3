//`timescale 1ns / 1ps

module fsm(
        input clk,resetn,
        input pkt_valid,
        input parity_done,
        input soft_reset_0,soft_reset_1,soft_reset_2,
        input fifo_empty_0,fifo_empty_1,fifo_empty_2,
        input fifo_full,
        input low_pkt_valid,
        input [1:0]data_in,

        output busy,
        output detect_add,
        output ld_state,lfd_state,laf_state,full_state,
        output write_en_reg,rst_int_reg
    );

    reg [2:0]present_state,next_state;
    reg [1:0]add;

    parameter DECODE_ADDRESS = 3'b000,
              LOAD_FIRST_DATA = 3'b001,
              LOAD_DATA = 3'b010,
              WAIT_TILL_EMPTY = 3'b011,
              FIFO_FULL_STATE = 3'b100,
              LOAD_AFTER_FULL = 3'b101,
              LOAD_PARITY = 3'b110,
              CHECK_PARITY_ERROR = 3'b111;


    always @ (posedge clk)
    begin
        if (~resetn)
            add <= 2'b0;
        else if (data_in == 1)
            add <= data_in;
        else
            add <= add;
    end

    // Present state logic
    always @ (posedge clk)
    begin
        if (~resetn)
            present_state <= DECODE_ADDRESS;
        else if (((soft_reset_0 == 1) && (data_in[1:0] == 2'b00 ))
                || ((soft_reset_1 == 1) && (data_in[1:0] == 2'b01 ))
                || ((soft_reset_2 == 1) && (data_in[1:0] == 2'b10 )) )
            present_state <= DECODE_ADDRESS;
        else
            present_state <= next_state;
    end


    // Nest state logic
    always @ (*)
    begin
        case (present_state)
            DECODE_ADDRESS: begin
                                if ((pkt_valid & (data_in[1:0] == 2'b00) & fifo_empty_0) || 
                                    (pkt_valid & (data_in[1:0] == 2'b01) & fifo_empty_1) || 
                                    (pkt_valid & (data_in[1:0] == 2'b10) & fifo_empty_2) )
                                    
                                    next_state = LOAD_FIRST_DATA;
                                    
                                else if ((pkt_valid & (data_in[1:0] == 2'b00) & ~fifo_empty_0) || 
                                    (pkt_valid & (data_in[1:0] == 2'b01) & ~fifo_empty_1) || 
                                    (pkt_valid & (data_in[1:0] == 2'b10) & ~fifo_empty_2) )
                                    
                                    next_state = WAIT_TILL_EMPTY;
                                    
                                else
                                    next_state = DECODE_ADDRESS;

                            end
            LOAD_FIRST_DATA:  begin
                                next_state = LOAD_DATA;
                              end
            LOAD_DATA:        begin
                                if (fifo_full)
                                    next_state = FIFO_FULL_STATE;
                                else if(~fifo_full && ~pkt_valid)
                                    next_state = LOAD_PARITY;
                                else
                                    next_state = LOAD_DATA;
                              end
            WAIT_TILL_EMPTY:  begin
                                if ((fifo_empty_0 && (add == 0)) || 
                                    (fifo_empty_1 && (add == 1)) || 
                                    (fifo_empty_2 && (add == 2)))
                                    next_state = LOAD_FIRST_DATA;
                                else
                                    next_state = WAIT_TILL_EMPTY;
                              end
            FIFO_FULL_STATE:  begin
                                if (~fifo_full)
                                    next_state = LOAD_AFTER_FULL;
                                else
                                    next_state = FIFO_FULL_STATE;
                              end
            LOAD_AFTER_FULL:  begin
                                if (~parity_done && low_pkt_valid)
                                    next_state = LOAD_PARITY;
                                else if (~parity_done && ~low_pkt_valid )
                                    next_state = LOAD_DATA;
                                else if (parity_done)
                                    next_state = DECODE_ADDRESS;
                                else
                                    next_state = LOAD_AFTER_FULL;
                              end
            LOAD_PARITY:      begin
                                next_state = CHECK_PARITY_ERROR;
                              end
            CHECK_PARITY_ERROR:   begin
                                    if (fifo_full)
                                        next_state = FIFO_FULL_STATE;
                                    else if (~fifo_full)
                                        next_state = DECODE_ADDRESS;
                                    else
                                        next_state = CHECK_PARITY_ERROR;
                                  end
        endcase
    end


    // Output logic


    assign busy = ((present_state == LOAD_DATA) | (present_state == DECODE_ADDRESS)) ? 1'b0 : 1'b1;

    assign detect_add = (present_state == DECODE_ADDRESS);

    assign lfd_state = (present_state == LOAD_FIRST_DATA);

    assign ld_state = (present_state == LOAD_DATA);

    assign laf_state = (present_state == LOAD_AFTER_FULL);

    assign full_state = (present_state == FIFO_FULL_STATE);

    assign write_en_reg = ((present_state == LOAD_DATA) || (present_state == LOAD_PARITY) || (present_state == LOAD_AFTER_FULL));

    assign rst_int_reg = (present_state == CHECK_PARITY_ERROR);


endmodule
