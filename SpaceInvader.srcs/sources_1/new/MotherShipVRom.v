`timescale 1ns / 1ps
module MotherShipVRom(
    input wire [9:0] i_MSaddr,
    input wire i_clk2,
    output reg [7:0] o_MSdata
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:1007]; //48*21

    initial begin
            $readmemh("Boss.mem", memory_array);
    end

    always @ (posedge i_clk2)
            o_MSdata <= memory_array[i_MSaddr];
endmodule