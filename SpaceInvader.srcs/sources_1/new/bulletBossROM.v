`timescale 1ns / 1ps

module bulletBossROM(
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
