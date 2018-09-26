module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period,
    input clk,
    input rst,
    output square_wave_out
);
  // YOUR CODE FROM LAB3 HERE.
  wire [23:0] clock_counter_max = tone_switch_period/2;
  reg [23:0] clock_counter = 0;
  reg flipping = 0;
  
  assign square_wave_out = flipping;
  
  always @(posedge clk)
  begin
  
  if(rst) begin
    clock_counter<=24'b0;
    flipping <= 0;
  end
    else begin
    if(output_enable == 0)
        begin
        flipping <= 0;
        end
    else
        begin
        clock_counter <= clock_counter + 1;
        if(clock_counter >= clock_counter_max)
            begin
            clock_counter <= 24'b0;
            if (tone_switch_period!=0) flipping <= ~flipping;
            end
        end
    end
  end
  
//  assign square_wave_out = 1'b0;
endmodule
