 `timescale 1ns / 1ps
 module Alien2Rom(
    input wire [9:0] i_A2addr, 
    input wire i_clk2,
    output reg [7:0] o_A2data 
    );

    (*ROM_STYLE="block"*) reg [7:0] A2memory_array [0:671]; //32*21

    initial begin
            $readmemh("InvaderNew02.mem", A2memory_array);
    end

    always @ (posedge i_clk2)
            o_A2data <= A2memory_array[i_A2addr];     
endmodule