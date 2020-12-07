`timescale 1ns / 1ps
module Seven_segment(
    input wire i_CLK,
    input wire i_reset,
    input wire gameover,
    output reg [3:0] o_an,
    output reg [6:0] o_seg
    );
    reg [26:0] one_second_counter; 
    wire one_second_enable;
    reg [15:0] displayed_number; 
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter;
    wire [1:0] LED_activating_counter; 
    always @(posedge i_CLK or posedge i_reset)
    begin
        if(i_reset==1) begin
            one_second_counter <= 0;
            end
        else begin
            if(one_second_counter>=99999999) 
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    assign one_second_enable = (one_second_counter==99999999)?1:0;
    always @(posedge i_CLK or posedge i_reset)
    begin
        if(i_reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1 && displayed_number != 9999 && gameover == 0)
            displayed_number <= displayed_number + 1;
    end
    always @(posedge i_CLK or posedge i_reset)
    begin 
        if(i_reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            o_an = 4'b0111; 
            LED_BCD = displayed_number/1000;
              end
        2'b01: begin
            o_an = 4'b1011; 
            LED_BCD = (displayed_number % 1000)/100;
              end
        2'b10: begin
            o_an = 4'b1101; 
            LED_BCD = ((displayed_number % 1000)%100)/10;
                end
        2'b11: begin
            o_an = 4'b1110; 
            LED_BCD = ((displayed_number % 1000)%100)%10; 
               end
        endcase
    end
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: o_seg = 7'b1000000; // "0"     
        4'b0001: o_seg = 7'b1111001; // "1" 
        4'b0010: o_seg = 7'b0100100; // "2" 
        4'b0011: o_seg = 7'b0110000; // "3" 
        4'b0100: o_seg = 7'b0011001; // "4" 
        4'b0101: o_seg = 7'b0010010; // "5" 
        4'b0110: o_seg = 7'b0000010; // "6" 
        4'b0111: o_seg = 7'b1111000; // "7" 
        4'b1000: o_seg = 7'b0000000; // "8"     
        4'b1001: o_seg = 7'b0010000; // "9" 
        default: o_seg = 7'b1000000; // "0"
        endcase
    end
endmodule
