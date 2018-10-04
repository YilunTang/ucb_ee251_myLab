module edge_detector #(
    parameter width = 1
)(
    input clk,
    input [width-1:0] signal_in,
    output [width-1:0] edge_detect_pulse
);

    // This module takes a vector of 1-bit signals as input and outputs a vector of 1-bit signals. For each input signal
    // this module will look for a low to high (0->1) logic transition, and should then output a 1 clock cycle wide pulse
    // for that signal.
    // Remove this line once you have implemented this module.
    
    
    reg [width-1:0] edges = 0;
    
    always @(posedge clk) begin
        edges <= signal_in;     
    end
    
    genvar i;
    generate
    for (i=0; i < width; i = i + 1) begin
        assign edge_detect_pulse[i] = ~edges[i] & signal_in[i];
    end
    endgenerate
    
    
endmodule
