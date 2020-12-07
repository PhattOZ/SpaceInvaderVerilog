`timescale 1ns / 1ps
module Alien1Rom(
    input wire [9:0] i_A1addr,
    input wire i_clk2,
    output reg [7:0] o_A1data
    );

    (*ROM_STYLE="block"*) reg [7:0] A1memory_array [0:671]; //32*21

    initial begin
            $readmemh("InvaderNew01.mem", A1memory_array);
    end

    always @ (posedge i_clk2)
            o_A1data <= A1memory_array[i_A1addr];     
endmodule