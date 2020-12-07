`timescale 1ns / 1ps
module BeeRom(
    input wire [9:0] i_addr, 
    input wire i_clk2,
    output reg [7:0] o_data 
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:447]; //28*16

    initial begin
            $readmemh("Spaceship.mem", memory_array);
    end

    always @ (posedge i_clk2)
            o_data <= memory_array[i_addr];     
endmodule