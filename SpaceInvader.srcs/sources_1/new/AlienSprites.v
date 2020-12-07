`timescale 1ns / 1ps

module AlienSprites(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg A1SpriteOn, // 1=on, 0=off
    output reg A2SpriteOn, // 1=on, 0=off
    output reg A3SpriteOn, // 1=on, 0=off
    output wire [7:0] A1dataout, // 8 bit pixel value from Alien1.mem
    output wire [7:0] A2dataout, // 8 bit pixel value from Alien2.mem
    output wire [7:0] A3dataout, // 8 bit pixel value from Alien3.mem
    output reg o_resetnext,
    output reg [4:0] o_gameround,
    input wire Pclk, // 25MHz pixel clock
    input wire i_reset,
    input wire HitEnemy,
    input wire gameover
    );

// instantiate Alien1Rom code
    reg [9:0] A1address; // 2^10 or 1024, need 31 x 26 = 806
    Alien1Rom Alien1VRom (.i_A1addr(A1address),.i_clk2(Pclk),.o_A1data(A1dataout));

// instantiate Alien2Rom code
    reg [9:0] A2address; // 2^10 or 1024, need 31 x 21 = 651
    Alien2Rom Alien2VRom (.i_A2addr(A2address),.i_clk2(Pclk),.o_A2data(A2dataout));

// instantiate Alien3Rom code
    reg [9:0] A3address; // 2^10 or 1024, need 31 x 27 = 837
    Alien3Rom Alien3VRom (.i_A3addr(A3address),.i_clk2(Pclk),.o_A3data(A3dataout));

// setup character positions and sizes
    reg [9:0] A1X = 135; // Alien1 X start position
    reg [9:0] A1Y = 90; // Alien1 Y start position
    localparam A1Width = 32; // Alien1 width in pixels
    localparam A1Height = 21; // Alien1 height in pixels
    reg [9:0] A2X = 135; // Alien2 X start position
    reg [9:0] A2Y = 120; // Alien2 Y start position
    localparam A2Width = 32; // Alien2 width in pixels
    localparam A2Height = 21; // Alien2 height in pixels
    reg [9:0] A3X = 135; // Alien3 X start position
    reg [9:0] A3Y = 180; // Alien3 Y start position
    localparam A3Width = 32; // Alien3 width in pixels
    localparam A3Height = 21; // Alien3 height in pixels

    reg [9:0] AoX = 0; // Offset for X Position of next Alien in row
    reg [9:0] AoY = 0; // Offset for Y Position of next row of Aliens
    reg [9:0] AcounterW = 0; // Counter to check if Alien width reached
    reg [9:0] AcounterH = 0; // Counter to check if Alien height reached
    reg [3:0] AcolCount = 11; // Number of horizontal aliens in all columns
    reg [1:0] A1Count [0:10];
    reg [1:0] A2Count [0:10];
    reg [1:0] A3Count [0:10];
    reg [1:0] A4Count [0:10];
    reg [1:0] A5Count [0:10];
    reg [3:0] Acount = 0;
    reg [3:0] Aycount = 0;
    reg [3:0] Aycount2 = 0;
    reg [1:0] Adir = 1;             // direction of aliens: 0=right, 1=left
    reg [9:0] delaliens=0;          // counter to slow alien movement
    integer i = 0;
    reg gameround = 0;
    always @ (posedge Pclk)
    begin
        if(A1Count[0] == 1 && A1Count[1] == 1 && A1Count[2] == 1 && A1Count[3] == 1 && A1Count[4] == 1 &&
           A1Count[5] == 1 && A1Count[6] == 1 && A1Count[7] == 1 && A1Count[8] == 1 && A1Count[9] == 1 &&
           A1Count[10] == 1 &&
           A2Count[0] == 1 && A2Count[1] == 1 && A2Count[2] == 1 && A2Count[3] == 1 && A2Count[4] == 1 &&
           A2Count[5] == 1 && A2Count[6] == 1 && A2Count[7] == 1 && A2Count[8] == 1 && A2Count[9] == 1 &&
           A2Count[10] == 1 &&
           A3Count[0] == 1 && A3Count[1] == 1 && A3Count[2] == 1 && A3Count[3] == 1 && A3Count[4] == 1 &&
           A3Count[5] == 1 && A3Count[6] == 1 && A3Count[7] == 1 && A3Count[8] == 1 && A3Count[9] == 1 &&
           A3Count[10] == 1 &&
           A4Count[0] == 1 && A4Count[1] == 1 && A4Count[2] == 1 && A4Count[3] == 1 && A4Count[4] == 1 &&
           A4Count[5] == 1 && A4Count[6] == 1 && A4Count[7] == 1 && A4Count[8] == 1 && A4Count[9] == 1 &&
           A4Count[10] == 1 &&
           A5Count[0] == 1 && A5Count[1] == 1 && A5Count[2] == 1 && A5Count[3] == 1 && A5Count[4] == 1 &&
           A5Count[5] == 1 && A5Count[6] == 1 && A5Count[7] == 1 && A5Count[8] == 1 && A5Count[9] == 1 &&
           A5Count[10] == 1
           )begin
                o_resetnext <= 1;
                gameround <= gameround + 1;
                o_gameround <= gameround;
           end
        else
            begin
                o_resetnext <= 0;
            end
        if(i_reset==1 || o_resetnext == 1 || gameover == 1) begin
                    for(i = 0; i < 11;i = i+1)
                        begin
                            A1Count[i] = 0;
                            A2Count[i] = 0;
                            A3Count[i] = 0;
                            A4Count[i] = 0;
                            A5Count[i] = 0;
                        end
                end
        else if (aactive)
            begin
                if(xx > 630) 
                    Acount <= 0;
                if(yy > 435)begin
                    Aycount <= 0;
                    Aycount2 <= 0;
                    end
                // check if xx,yy are within the confines of the Alien characters
                // Alien1
                if (xx==A1X+AoX-1 && yy==A1Y+AoY && A1Y+A1Height <=460 && gameover == 0)
                    begin
                        A1address <= 0;
                        AcounterW <= 0;
                        if(HitEnemy == 1)
                            begin
                                A1Count[Acount] = 1;
                                A1SpriteOn <= 0;
                            end
                        if(A1Count[Acount] == 0)
                            begin
                                A1SpriteOn <= 1;
                            end
                    end                   
                if ((xx>A1X+AoX-1) && (xx<A1X+A1Width+AoX) && 
                    (yy>A1Y+AoY-1) && (yy<A1Y+A1Height+AoY) && 
                    (A1Y+A1Height <=460) && gameover == 0)   
                    begin
                        A1address <= A1address + 1;
                        AcounterW <= AcounterW + 1;
                        if(HitEnemy == 1)
                            begin
                                A1Count[Acount] = 1;
                                A1SpriteOn <= 0;
                            end
                        if(A1Count[Acount] == 0)
                            A1SpriteOn <= 1;
                        if (AcounterW==A1Width-1)
                            begin
                                Acount <= Acount + 1;
                                AcounterW <= 0;
                                AoX <= AoX + 40;
                                if(AoX<(AcolCount-1)*40)
								    A1address <= A1address - (A1Width-1);
							    else
							    if(AoX==(AcolCount-1)*40)
								    AoX<=0;
					        end
                    end
                else
                    begin
                        A1SpriteOn <=0;
                    end
                    
                // Alien2    
                if (xx==A2X+AoX-1 && yy==A2Y+AoY && A2Y+A2Height <=460 && gameover == 0)
                    begin
                        A2address <= 0;
                        AcounterW<=0;
                        if(HitEnemy == 1)
                            begin
                                if(Aycount == 0)
                                    A2Count[Acount] = 1;
                                else if(Aycount == 1)
                                    A3Count[Acount] = 1;
                                A2SpriteOn <= 0;
                            end
                        else if(A2Count[Acount] == 0 && Aycount == 0)
                            begin
                                A2SpriteOn <= 1;
                            end
                        else if(A3Count[Acount] == 0 && Aycount == 1)
                            begin
                                A2SpriteOn <= 1;
                            end
                    end
                if ((xx>A2X+AoX-1) && (xx<A2X+A2Width+AoX) && 
                    (yy>A2Y+AoY-1) && (yy<A2Y+AoY+A2Height) && 
                    (A2Y+A2Height <=460) && gameover == 0)
                    begin
                        A2address <= A2address + 1;
                        AcounterW <= AcounterW + 1;
                        if(HitEnemy == 1)
                            begin
                                if(Aycount == 0)
                                    A2Count[Acount] = 1;
                                else if(Aycount == 1)
                                    A3Count[Acount] = 1;
                                A2SpriteOn <= 0;
                            end
                        if(A2Count[Acount] == 0 && Aycount == 0)
                            begin
                                A2SpriteOn <= 1;
                            end
                        else if(A3Count[Acount] == 0 && Aycount == 1)
                            begin
                                A2SpriteOn <= 1;
                            end
                        if (AcounterW==A2Width-1)
                            begin
                                Acount <= Acount + 1;
                                AcounterW <= 0;
                                AoX <= AoX + 40;
                                if(AoX<(AcolCount-1)*40)
								    A2address <= A2address - (A2Width-1);
							    else
							    if(AoX==(AcolCount-1)*40)
                                    begin
								        AoX<=0;
								        AcounterH <= AcounterH + 1;
								        if(AcounterH==A2Height-1)
                                            begin
                                                Aycount <= Aycount + 1;
							                    AcounterH<=0;
							                    AoY <= AoY + 30;
							                    if(AoY==30)
							                        begin
								                        AoY<=0;
								                        AoX<=0;
				                                    end
						                    end
                                    end
                            end         
                    end
                else
                    begin
                        A2SpriteOn <=0;
                    end
                    
                // Alien3
                if (xx==A3X+AoX-1 && yy==A3Y+AoY && A3Y+A3Height <=460 && gameover == 0)
                    begin
                        A3address <= 0;
                        AcounterW<=0;
                        AcounterH<=0;
                        if(HitEnemy == 1)
                            begin
                                if(Aycount2 == 0)
                                    A4Count[Acount] = 1;
                                else if(Aycount2 == 1)
                                    A5Count[Acount] = 1;
                                A3SpriteOn <= 0;
                            end
                        else if(A4Count[Acount] == 0 && Aycount2 == 0)
                            begin
                                A3SpriteOn <= 1;
                            end
                        else if(A5Count[Acount] == 0 && Aycount2 == 1)
                            begin
                                A3SpriteOn <= 1;
                            end
                    end
                if ((xx>A3X+AoX-1) && (xx<A3X+AoX+A3Width) && 
                    (yy>A3Y+AoY-1) && (yy<A3Y+AoY+A3Height) && 
                    (A3Y+A3Height <=460) && gameover == 0)
                    begin
                        A3address <= A3address + 1;
                        AcounterW <= AcounterW + 1;
                        if(HitEnemy == 1)
                            begin
                                if(Aycount2 == 0)
                                    A4Count[Acount] = 1;
                                else if(Aycount2 == 1)
                                    A5Count[Acount] = 1;
                                A3SpriteOn <= 0;
                            end
                        if(A4Count[Acount] == 0 && Aycount2 == 0)
                            begin
                                A3SpriteOn <= 1;
                            end
                        else if(A5Count[Acount] == 0 && Aycount2 == 1)
                            begin
                                A3SpriteOn <= 1;
                            end
                        if (AcounterW==A3Width-1)
                            begin
                                Acount <= Acount + 1;
                                AcounterW <= 0;
                                AoX <= AoX + 40;
                                if(AoX<(AcolCount-1)*40)
								    A3address <= A3address - (A3Width-1);
							    else
							    if(AoX==(AcolCount-1)*40)
                                    begin
								        AoX<=0;
								        AcounterH <= AcounterH + 1;
								        if(AcounterH==A3Height-1)
                                            begin
                                                Aycount2 <= Aycount2 + 1;
							                    AcounterH<=0;
							                    AoY <= AoY + 30;
							                    if(AoY==30)
							                        begin
								                        AoY<=0;
								                        AoX<=0;
				                                    end
						                    end
								    end	    
					        end
                    end
                else
                    begin
                        A3SpriteOn <=0;
                    end
            end
        /*if(Acount == 55)
            begin
                Acount <= 0;
            end*/
    end
    localparam Xspeed = 10;
    localparam Yspeed = 33;
   
    always @ (posedge Pclk)
    begin
        // slow down the alien movement / move aliens left or right
        if(i_reset==1 || o_resetnext == 1) begin
            A1X <= 135; // Alien1 X start position
            A1Y <= 90; // Alien1 Y start position
            A2X <= 135; // Alien2 X start position
            A2Y <= 120; // Alien2 Y start position
            A3X <= 135; // Alien3 X start position
            A3Y <= 180; // Alien3 Y start position
            end
        else if (xx==639 && yy==479)
            begin
                delaliens<=delaliens+1;
                if (delaliens>20)
                    begin
                        delaliens<=0;
                        if (Adir==1)
                            begin
                                A1X<=A1X-Xspeed;
                                A2X<=A2X-Xspeed;
                                A3X<=A3X-Xspeed;
                                if (A1X<30)
                                begin
                                    Adir<=0;
                                    A1Y<=A1Y+Yspeed;
                                    A2Y<=A2Y+Yspeed;
                                    A3Y<=A3Y+Yspeed;
                                end
                            end
                        if (Adir==0)
                            begin
                                A1X<=A1X+Xspeed;
                                A2X<=A2X+Xspeed;
                                A3X<=A3X+Xspeed;
                                if (A1X+A1Width+((AcolCount-1)*40)>620)    
                                    begin
                                    Adir<=1;
                                    A1Y<=A1Y+Yspeed;
                                    A2Y<=A2Y+Yspeed;
                                    A3Y<=A3Y+Yspeed;
                                    end
                            end
                    end
            end
    end
endmodule

