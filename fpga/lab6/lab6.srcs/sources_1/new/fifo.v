`include "util.vh"

module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout,
    output empty
);
    reg [data_width-1:0] data[fifo_depth-1:0];
    reg [addr_width:0] w_pointer = 0;
    reg [addr_width:0] r_pointer = 0;

    always @(posedge clk) begin
        if(rst) begin
            w_pointer <= 0;
            r_pointer <= 0;
        end
        else begin
            if (wr_en) begin
            if(!full) begin
                data[w_pointer[addr_width-1:0]] <= din;
                w_pointer <= w_pointer + 1;
            end
            end
        
            if (rd_en) begin
            if(!empty) begin
                dout <= data[r_pointer[addr_width-1:0]];
                r_pointer <= r_pointer + 1;
            end
        end
        end
    end
    
    assign full = (w_pointer - r_pointer == fifo_depth);
    assign empty = (w_pointer - r_pointer == 0);
//    assign dout = 0;

endmodule
