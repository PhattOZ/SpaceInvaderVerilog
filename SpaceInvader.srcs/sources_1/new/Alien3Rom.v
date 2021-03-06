`timescale 1ns / 1ps

module Alien3Rom(
    input wire [9:0] i_A3addr, 
    input wire i_clk2,
    output reg [7:0] o_A3data 
    );

    (*ROM_STYLE="block"*) reg [7:0] A3memory_array [0:671]; //32*21

    initial begin
            $readmemh("InvaderNew03.mem", A3memory_array);
    end

    always @ (posedge i_clk2)
            o_A3data <= A3memory_array[i_A3addr];     
endmodule