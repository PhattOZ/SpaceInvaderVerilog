`timescale 1ns / 1ps

module motherBulletSprite(
    input wire [9:0] xx, // Current refresh position
    input wire [9:0] yy, // Current refresh position
    input wire aactive,
    input [9:0] shipX,
    input [9:0] shipY,
    input wire Pclk,
    input wire gameover,
    input wire i_reset,
    input wire i_resetnext,
    input wire [4:0] i_gameround,
    output reg BulletSpriteOn,
    output wire [7:0] dataout
    );
    
     // Retrieve address from always block below
    reg [5:0] address;
    bulletBossROM bulletBoss (.i_addr(address), .i_clk(Pclk), .o_data(dataout));
    
    reg [3:0] bulletSpeed = 6;
    localparam BulletWidth = 4;
    localparam BulletHeight = 14;
    
    reg [9:0] BulletX; // Current bullet position
    reg [8:0] BulletY; // Current bullet position
    
    reg [24:0] accumulateClk = 0;
    reg [8:0] accumulateSec = 0;
    reg [8:0] delaysec = 3;
    reg firing = 0;     // 0: bullet not fire, 1: bullet is firing
    
    always @ (posedge Pclk)
    begin
        if(i_reset || gameover || i_resetnext)
            begin
                accumulateSec <= 0;
                accumulateClk <= 0;
                BulletSpriteOn <=0;
            end
        else
            begin   
                accumulateClk <= accumulateClk + 1;
            end
        if(i_resetnext)
            begin
                if(delaysec > 0)
                    delaysec <= delaysec -1;
                else if(bulletSpeed < 16)
                    bulletSpeed <= bulletSpeed + 1;
            end
        else if(i_reset || gameover)
            begin
                delaysec <= 3;
            end
        if(accumulateClk == 25000000)
            begin
                accumulateClk <= 0;
                accumulateSec <= accumulateSec + 1;
            end     
        if(!firing && accumulateSec >= delaysec && !i_reset && !gameover)   // if press a button and ship is not firing
            begin
                BulletX <= shipX + 20;     // Set bullet's position
                BulletY <= shipY;
                firing <= 1;         // Set state to firing
                accumulateSec <= 0;
            end
        if(xx==639 && yy == 479 && firing)
            begin
                if(BulletY + bulletSpeed >= 450)
                    begin
                        firing <= 0;
                        BulletSpriteOn <=0;
                    end
                else
                    begin
                        BulletY <= BulletY + bulletSpeed;
                    end
            end
        if(aactive && firing)
            begin
                if(xx==BulletX-1 && yy==BulletY)
                    begin
                        address <= 0;
                        BulletSpriteOn <= 1;
                    end
                if((xx>BulletX-1) && (xx<BulletX+BulletWidth) && (yy>BulletY-1) && (yy<BulletY+BulletHeight))
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
