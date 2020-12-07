`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2020 05:29:16 PM
// Design Name: 
// Module Name: bulletROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bulletROM(
    input wire [5:0] i_addr,
    input wire i_clk,
    output reg [7:0] o_data
    );
    
    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:55]; //4*14
    
    initial begin
            $readmemh("Bullet.mem", memory_array);
    end
    
    always @ (posedge i_clk)
            o_data <= memory_array[i_addr];
    
endmodule

