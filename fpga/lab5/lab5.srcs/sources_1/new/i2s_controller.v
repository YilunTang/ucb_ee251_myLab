`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

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
localparam LRCK_CYCLES = MCLK_TO_LRCK_RATIO;
localparam LRCK_COUNTER_WIDTH = `log2(LRCK_CYCLES);
localparam LRCK_CYCLES_HALF = `divceil(LRCK_CYCLES, 2);

//localparam SCLK_CYCLES = `divceil(LRCK_FREQ_HZ, 2*24);
localparam SCLK_CYCLES = `divceil(LRCK_CYCLES, 2*16);
localparam SCLK_COUNTER_WIDTH = `log2(SCLK_CYCLES);
localparam SCLK_CYCLES_HALF = `divceil(SCLK_CYCLES, 2);

reg [MCLK_COUNTER_WIDTH-1:0] mclk_counter = 0;
reg [LRCK_COUNTER_WIDTH-1:0] lrck_counter = 0;
reg [SCLK_COUNTER_WIDTH-1:0] sclk_counter = 0;

assign mclk = mclk_counter >= MCLK_CYCLES_HALF ? 1:0;
assign lrck = lrck_counter >= LRCK_CYCLES_HALF ? 1:0;
assign sclk = sclk_counter >= SCLK_CYCLES_HALF ? 1:0;
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
always @(posedge mclk)begin
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
always @(posedge mclk)begin
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
endmodule