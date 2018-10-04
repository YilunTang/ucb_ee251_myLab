`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);
    localparam  SAMPLE_TIME = SYMBOL_EDGE_TIME / 2;

    // Remove these assignments when implementing this module
//    assign serial_out = 1'b0;
//    assign data_in_ready = 1'b0;
    
    //Notes:
    // whenever we are not transmitting anything, data_in_ready should be high and 
    // we will be waiting for a data_in_valid signal that becomes high
    
    // once valid becomes valid, we want to pull that data immediately and store it locally (clocked)
    
    // then we should start the sending routine.
    
    // which means that each clock, we pump out data in serial out
    
    // first, we start by pulling serial out low, for one clock
    // then, we start sending data
    // finally, we will push the serial out high again to say we are done now.
    // Of course, we will only send one data depending on clk / baudrate. 
    
    // After that, we will again push data in read to high, to tell that we are ready to transmit more
    // data now. 
    
    reg [3:0] bit_counter = 4'd0;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;
    reg start_sig = 1'b0;
    reg end_sig = 1'b1;
    reg [7:0] internal_data;
    
    wire start;
    wire [9:0] all_data = {end_sig, internal_data, start_sig};
    
    assign start = data_in_valid;
    assign tx_running = bit_counter != 4'd0;
    assign data_in_ready = ~tx_running;
    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);
    
    always @ (posedge clk) begin
            if (reset) begin
                bit_counter <= 0;
                internal_data <= 8'b0;
            end else if (start && ~tx_running) begin
                internal_data <= data_in;
                bit_counter <= 10;
            end else if (symbol_edge && tx_running) begin
                bit_counter <= bit_counter - 1;
            end
        end
        
    always @ (posedge clk) begin
                    if (reset) begin
                        clock_counter <= 0;
                    end else if (tx_running) begin
                        clock_counter <= clock_counter + 1;
                    end
                    
                    if(clock_counter == SYMBOL_EDGE_TIME-1)begin
                        clock_counter <= 0;
                    end
                end

    assign serial_out = (bit_counter == 4'b0000) ? 1'b1 : all_data[10-bit_counter];
    
endmodule
