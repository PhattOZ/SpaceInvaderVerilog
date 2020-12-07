`timescale 1ns / 1ps

module mouse_led(
    input wire clk, reset,
    inout wire ps2d, ps2c,
    output reg p_reg,
    output wire [8:0] xm,
    output wire m_done_tick
    );
    
    wire p_next;
    wire [2:0] btnm;
    
    mouse mouse_unit (.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c),
                      .xm(xm), .ym(), .btnm(btnm),
                      .m_done_tick(m_done_tick));
                      
    always @(posedge clk, posedge reset)
    begin
        
        if(reset)
            begin
                p_reg <= 0;
//                direction <= 0;
            end
        else
            begin
                p_reg <= p_next;
            end
    end
    
    assign p_next = (~m_done_tick)  ? p_reg  :
                    btnm[0]         ? 1 :
                    0;
//    assign next_direction =  xm > 0 ? 1 : 0;
    
//    assign p_next = (~m_done_tick) ? p_reg :        // no activity
//                    (btnm[0])      ? 1 :        // left button is pressed
//                    (btnm[1])      ? 0 :      // right button is pressed
//                    p_reg + {xm[8], xm};            // X-axis movement - xm[8]=0: move right, xm[8]=1: move left
                    
//    always @(*)
//    begin
//        case (p_reg[9:7])
//            3'b000:  led = 8'b10000000;
//            3'b001:  led = 8'b01000000;
//            3'b010:  led = 8'b00100000;
//            3'b011:  led = 8'b00010000;
//            3'b100:  led = 8'b00001000;
//            3'b101:  led = 8'b00000100;
//            3'b110:  led = 8'b00000010;
//            default: led = 8'b00000001;
//        endcase
//    end
endmodule
