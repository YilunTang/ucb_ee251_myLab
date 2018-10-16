`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128,
  parameter BITWIDTH = 24
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived
  
  input [BITWIDTH-1:0] in,
  input fifo_empty,
  output fifo_read,
  output out,
  //output [1:0]out_valid,

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data - UNUSED IN THIS LAB.
);

// An idea of what you might need, to get you started.
localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);

//localparam LRCK_CYCLES = `divceil(SYS_CLOCK_FREQ, LRCK_FREQ_HZ);
localparam LRCK_CYCLES = MCLK_TO_LRCK_RATIO * MCLK_CYCLES;
localparam LRCK_COUNTER_WIDTH = `log2(LRCK_CYCLES);
localparam LRCK_CYCLES_HALF = `divceil(LRCK_CYCLES, 2);

//localparam SCLK_CYCLES = `divceil(LRCK_FREQ_HZ, 2*24);
localparam SCLK_CYCLES = `divceil(LRCK_CYCLES, 2*BITWIDTH);
localparam SCLK_COUNTER_WIDTH = `log2(SCLK_CYCLES);
localparam SCLK_CYCLES_HALF = `divceil(SCLK_CYCLES, 2);

localparam BITWIDTH_WIDTH = `log2(BITWIDTH);

localparam MAX = 20'h7FFFF;
localparam MIN = 20'h80000;

reg [MCLK_COUNTER_WIDTH-1:0] mclk_counter = 0;
reg [LRCK_COUNTER_WIDTH-1:0] lrck_counter = 0;
reg [SCLK_COUNTER_WIDTH-1:0] sclk_counter = 0;

reg [BITWIDTH-1:0] data_hold  = 0;

// reg left_valid = 0;
// reg right_valid = 0;
wire fifo_read_en;
reg [BITWIDTH_WIDTH-1:0] bitcounter = 0;

assign fifo_read = fifo_read_en;
assign mclk = mclk_counter >= MCLK_CYCLES_HALF ? 1:0;
assign lrck = lrck_counter >= LRCK_CYCLES_HALF ? 1:0;
assign sclk = sclk_counter >= SCLK_CYCLES_HALF ? 1:0;

//data_fifo #(
//        .DATA_WIDTH(),
//        .FIFO_DEPTH()
//    ) fifo (
//        .clk(clk),
//        .reset(sys_reset),
//        .wr_en(data_in),
//        .din(data_in_valid),
//        .full(data_in_ready),
//        .rd_en(serial_out_tx),
//        .dout(),
//        .empty()
//    );

// 1: Generate MCLK from sys_clk. MCLK's frequency must be an integer multiple
// of the sample rate, and hence LRCK rate, as defined in the PMOD I2S reference
// manual and the Cirrus Logic CS4344 data sheet.
always @(posedge sys_clk)begin
    if(sys_reset)begin
        mclk_counter<=0;
    end
    else if(mclk_counter == MCLK_CYCLES-1) begin
        mclk_counter <= 0;
    end
    else begin
        mclk_counter <= mclk_counter + 1;
    end
end
// 2: Generate the LRCK, the left-right clock.
always @(posedge sys_clk)begin
    if(sys_reset)begin
        lrck_counter<=0;
    end
    else if(lrck_counter == LRCK_CYCLES-1) begin
            lrck_counter <= 0;
        end
        else begin
            lrck_counter <= lrck_counter + 1;
        end
end
// 3. Generate the bit clock, or serial clock. It clocks transmitted bits for a 
// whole sample on each half-cycle of the lr_clock. The frequency of this clock
// relative to the lr_clock determines how wide our samples can be.
always @(posedge sys_clk)begin
    if(sys_reset)begin
        sclk_counter<=0;
    end
    else if(sclk_counter == SCLK_CYCLES-1) begin
        sclk_counter <= 0;
    end
    else begin
        sclk_counter <= sclk_counter + 1;
    end
end



always @(negedge lrck)  begin
 sclk_counter <= 0;
    bitcounter <= 0;
end

always @(posedge lrck)  begin
 sclk_counter <= 0;
    bitcounter <= 0;
end

reg temp = 0;

always @(posedge sclk)begin
 
    if(sys_reset) begin
        //do something
    end
   
    bitcounter <= bitcounter + 1;
    
    temp <= data_hold[BITWIDTH-1-bitcounter];
end


assign fifo_read_en = (bitcounter == 0) && ~fifo_empty;

always @(posedge sclk) begin
    
    if (fifo_read_en) begin
        data_hold <= in;
    end
    else data_hold <= data_hold;
end

assign out = temp;


    /*
    else if (right_start || left_start) begin
        if (!fifo_read_en)    fifo_read_en <= 1;
    end
    else if(fifo_read_en && right_start && !fifo_empty)begin
        fifo_data_hold_right <= in;
    end
    else if(fifo_read_en && left_start && !fifo_empty)begin
            fifo_data_hold_left <= in;
    end
    */
/*
always @(*)begin
    if(left_valid) begin
        if(fifo_data_hold_left <= MAX) begin
            temp = 1;
        end
        else if (fifo_data_hold_left >= MIN)begin
            temp = 0;
        end
    end
    if(right_valid)begin
        if(fifo_data_hold_right <= MAX)begin
                temp = 1;
            end
            else if (fifo_data_hold_right >= MIN)begin
                temp = 0;
            end
    end
end
*/
// assign out_valid = {left_valid, right_valid};

endmodule