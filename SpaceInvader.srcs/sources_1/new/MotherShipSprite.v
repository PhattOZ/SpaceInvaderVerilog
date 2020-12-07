`timescale 1ns / 1ps
module MotherShipSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg MSSpriteOn, // 1=on, 0=off
    output wire [7:0] MSdataout, // 8 bit pixel value from Alien1.memm
    input wire Pclk, // 25MHz pixel clock
    input wire i_reset,
    input wire i_resetnext,
    input wire gameover,
    output reg[9:0] bossXOUT,
    output reg[9:0] bossYOUT
    );

// instantiate Alien1Rom code
    reg [9:0] MSaddress;
    MotherShipVRom MSVRom (.i_MSaddr(MSaddress),.i_clk2(Pclk),.o_MSdata(MSdataout));

// setup character positions and sizes
    reg [9:0] MSX = 272; // Alien1 X start position
    reg [9:0] MSY = 40; // Alien1 Y start position
    localparam MSWidth = 48; // Alien1 width in pixels
    localparam MSHeight = 21; // Alien1 height in pixels

    reg [1:0] Adir = 1;             // direction of aliens: 0=right, 1=left
    //reg [9:0] delaliens=0;
    
    always @ (posedge Pclk)
    begin
        if(i_reset==1 || i_resetnext == 1) begin
            MSX <= 272;
            MSY <= 40;
            end
        else if (xx==639 && yy==479)
            begin
                        if (Adir==1)
                            begin
                                MSX<=MSX-1;
                                if (MSX<10)
                                begin
                                    Adir<=0;
                                end
                            end
                        if (Adir==0)
                            begin
                                MSX<=MSX+1;
                                if (MSX+MSWidth>640)    
                                    begin
                                    Adir<=1;
                                    end
                            end
            end
        if (aactive)
            begin 
                // check if xx,yy are within the confines of the Alien characters
                if (xx==MSX-1 && yy==MSY && gameover == 0)
                    begin
                        MSaddress <= 0;
                        MSSpriteOn <=1;
                    end                   
                if ((xx>MSX-1) && (xx<MSX+MSWidth) && (yy>MSY-1) && (yy<MSY+MSHeight) && gameover == 0)   
                    begin
                        MSaddress <= MSaddress + 1;
                        MSSpriteOn <=1;
                    end
                else
                    MSSpriteOn <=0;
            end
        bossXOUT <= MSX;
        bossYOUT <= MSY;
    end
endmodule