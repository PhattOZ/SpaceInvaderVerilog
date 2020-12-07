`timescale 1ns / 1ps
/*
Pls setup Top.v and .xdc before run!!!!!!!!!!
=================================================
Top.v
- add input for button for fire
    input btnD
- add
    wire shipBulletSpriteOn;
    wire [7:0] shipBulletDataOut;
    bulletSprite bullet (.xx(x),.yy(y),.aactive(active), .beeX(beeX), .beeY(beeY),
                          .BulletSpriteOn(shipBulletSpriteOn),.dataout(shipBulletDataOut),
                          .Pclk(PixCLK), .fireButton(btnD));
- add this in render part
    else if (shipBulletSpriteOn==1)
                    begin
                        RED <= (palette[(shipBulletDataOut*3)])>>4; // RED bits(7:4) from colour palette
                        GREEN <= (palette[(shipBulletDataOut*3)+1])>>4; // GREEN bits(7:4) from colour palette
                        BLUE <= (palette[(shipBulletDataOut*3)+2])>>4; // BLUE bits(7:4) from colour palette
                    end
=================================================
.xdc file
add button
*/

module bulletSprite(
    input wire [9:0] xx,    // Current refresh position
    input wire [9:0] yy,    // Current refresh position
    input wire aactive,
    input [9:0] beeX,       // Ship X-axis position
    input [9:0] beeY,       // Ship Y-axis position
    input wire fireButton,
    input wire Pclk,        // Board's clock
    input wire gameover,
    input wire i_reset,
    input wire HitEnemy,
    output reg BulletSpriteOn,      // Sprite active 1:on 0:off
    output wire [7:0] dataout       // Sprite color data

    );
    
    // Retrieve address from always block below
    reg [5:0] address;
    bulletROM bullet (.i_addr(address), .i_clk(Pclk), .o_data(dataout));
    
    localparam bulletSpeed = 10;
    localparam BulletWidth = 4;
    localparam BulletHeight = 14;
    
    reg [9:0] BulletX; // Current bullet position
    reg [8:0] BulletY; // Current bullet position
    
    reg firing = 0;     // 0: bullet not fire, 1: bullet is firing
    
    always @ (posedge Pclk)
    begin
        if(i_reset || gameover || HitEnemy)
            begin
                BulletSpriteOn <=0;
                firing <= 0;
            end
        if(fireButton && !firing && !i_reset && !gameover && !HitEnemy)   // if press a button and ship is not firing
            begin
                BulletX <= beeX + 20;     // Set bullet's position
                BulletY <= beeY;
                firing <= 1;         // Set state to firing
            end
        if(xx==639 && yy == 479 && firing)
            begin
                if(BulletY - bulletSpeed < 60)
                    begin
                        BulletSpriteOn <=0;
                        firing <= 0;
                    end
                else
                    begin
                        BulletY <= BulletY - bulletSpeed;
                    end
            end
        if(aactive && firing)
            begin
                if(xx==BulletX-1 && yy==BulletY)
                    begin
                        address <= 0;
                        BulletSpriteOn <= 1;
                    end
                if((xx>BulletX-1) && (xx<BulletX+BulletWidth) && 
                   (yy>BulletY-1) && (yy<BulletY+BulletHeight))
                    begin
                        address <= address + 1;
                        BulletSpriteOn <= 1;
                    end
                else 
                    begin
                        BulletSpriteOn <=0;
                    end
            end
    end
endmodule
