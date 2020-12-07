`timescale 1ns / 1ps
module GameOVVRom(
    input wire [14:0] i_GOaddr,
    input wire i_clk2,
    output reg [7:0] o_GOdata
    );

    (*ROM_STYLE="block"*) reg [7:0] GOmemory_array [0:23599]; //236*100

    initial begin
            $readmemh("Gameover5.mem", GOmemory_array);
    end

    always @ (posedge i_clk2)
            o_GOdata <= GOmemory_array[i_GOaddr];
endmodule