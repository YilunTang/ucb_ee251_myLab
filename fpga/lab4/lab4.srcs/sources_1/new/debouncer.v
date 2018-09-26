`include "util.vh"


module pulse_generator #(
    parameter sample_count_max = 25000,
    parameter wrapping_counter_width = `log2(sample_count_max) )
(   input clk,
    output pulse
);
    
    reg [wrapping_counter_width-1:0] wrap_counter = 0;
    
    assign pulse = (wrap_counter == sample_count_max); 
    
    always @(posedge clk) begin
        if (wrap_counter >= sample_count_max) begin
            wrap_counter <= 0;
        end
        else wrap_counter <= wrap_counter + 1;
    end
    
endmodule


module checker #(
    parameter sample_count_max = 25000,
    parameter wrapping_counter_width = `log2(sample_count_max) )
(   input clk,
    output pulse
);
    
    reg [wrapping_counter_width-1:0] wrap_counter = 0;
    
    assign pulse = (wrap_counter == sample_count_max); 
    
    always @(posedge clk) begin
        if (wrap_counter == sample_count_max) begin
            wrap_counter <= 0;
        end
        else  wrap_counter <= wrap_counter + 1;
    end
    
endmodule



module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = `log2(sample_count_max),
    parameter saturating_counter_width = `log2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);
    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that hold high when their respective counter saturates

    // Remove this line once you create your synchronizer
    
    
    
    wire pulse;
    
    
    pulse_generator #(.sample_count_max(sample_count_max),
                      .wrapping_counter_width(wrapping_counter_width)) pg(
                      .clk(clk), 
                      .pulse(pulse)  );
    
    reg [saturating_counter_width-1:0] sat_counter [width-1:0];
    
    
    integer j;
    initial begin
         for (j = 0; j < width; j = j + 1) begin:initloop
               sat_counter[j] <= 0;
          end
    end
    
    genvar i;
    generate
        for (i = 0; i < width; i = i+1 ) begin:loop
        
            assign debounced_signal[i] = (sat_counter[i] == pulse_count_max);
        
            always @(posedge clk) 
            begin
                if (~glitchy_signal[i]) begin
                    sat_counter[i] <= 0;
                end
               
                if ((sat_counter[i] < pulse_count_max) && (pulse && glitchy_signal[i])) begin
                    sat_counter[i] <= sat_counter[i] + 1 ;
                end
            end
            
        end
    endgenerate
    
    

endmodule

