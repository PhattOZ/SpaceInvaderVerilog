`timescale 1ns / 1ps
module GameOVSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg SpriteOn, // 1=on, 0=off
    output wire [7:0] GOdataout, // 8 bit pixel value from Bee.mem
    input wire gameover,
    input wire Pclk // 25MHz pixel clock
    );

    // instantiate BeeRom code
    reg [14:0] address; // 2^15 or 32768, need 216*100 = 21600
    GameOVVRom GOVRom (.i_GOaddr(address),.i_clk2(Pclk),.o_GOdata(GOdataout));
            
    // setup character positions and sizes 640*480
    reg [9:0] GOX = 212; // Bee X start position
    reg [8:0] GOY = 190; // Bee Y start position
    localparam GOWidth = 236; // Bee width in pixels
    localparam GOHeight = 100; // GO height in pixels
    always @ (posedge Pclk)
    begin
        if (aactive)
            begin // check if xx,yy are within the confines of the GO character
                if (xx==GOX-1 && yy==GOY && gameover == 1)
                    begin
                        address <= 0;
                        SpriteOn <=1;
                    end
                if ((xx>GOX-1) && (xx<GOX+GOWidth) && (yy>GOY-1) && (yy<GOY+GOHeight) && gameover == 1)
                    begin
                        address <= address + 1;
                        SpriteOn <=1;
                    end
                else
                    SpriteOn <=0;
            end
    end
endmodule
