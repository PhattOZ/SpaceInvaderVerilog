`timescale 1ns / 1ps
module Top(
    input wire CLK,
    input wire RESET,
    output wire HSYNC,
    output wire VSYNC,
    output reg [3:0] RED,
    output reg [3:0] GREEN,
    output reg [3:0] BLUE,
    output reg [3:0] an,
    output reg [6:0] seg,
    input btnU,
    input btnR,
    input btnD,
    input btnL,
    
    // Mouse
    inout ps2d, ps2c
    );
    
    wire mouse_click_out;
    wire m_done_tick;
    wire [8:0] xm;
    
    // Mouse
    mouse_led mouse (.clk(CLK), .reset(RESET), .ps2d(ps2d), .ps2c(ps2c),
                    .p_reg(mouse_click_out), .xm(xm), .m_done_tick(m_done_tick));
    
    wire rst = RESET;
    wire [3:0] Anode_Activate = an;
    wire [6:0] lcd_seg = seg;
    reg GameOver = 0;
    reg HitEnemy = 0;
    Seven_segment(.i_CLK(CLK),.i_reset(rst),.gameover(GameOver),
                  .o_an(Anode_Activate),.o_seg(lcd_seg));
    
    // instantiate vga640x480 code
    wire [9:0] x; // pixel x position: 10-bit value: 0-1023 : only need 800
    wire [9:0] y; // pixel y position: 10-bit value: 0-1023 : only need 525
    wire active; // high during active pixel drawing
    wire PixCLK; // 25MHz pixel clock
    vga640x480 display (.i_clk(CLK),.i_rst(rst),.o_hsync(HSYNC), 
                        .o_vsync(VSYNC),.o_x(x),.o_y(y),.o_active(active),
                        .pix_clk(PixCLK));
      
    // instantiate BeeSprite code
    wire ShipSpriteOn;
    wire [7:0] dout;
    wire [9:0] beeX, beeY;
    BeeSprite BeeDisplay (.xx(x),.yy(y),.aactive(active),
                          .BSpriteOn(ShipSpriteOn),.dataout(dout),.BR(btnR),
                          .BL(btnL),.Pclk(PixCLK),.gameover(GameOver),.i_reset(rst),
                          .beeXOUT(beeX), .beeYOUT(beeY), .xm(xm), .m_done_tick(m_done_tick));
                          
    // instantiate AlienSprites code
    wire Alien1SpriteOn;
    wire Alien2SpriteOn;
    wire Alien3SpriteOn;
    wire [7:0] A1dout;
    wire [7:0] A2dout;
    wire [7:0] A3dout;
    wire rstnext;
    wire [4:0] gameround;
    AlienSprites ADisplay (.xx(x),.yy(y),.aactive(active),
                          .A1SpriteOn(Alien1SpriteOn),.A2SpriteOn(Alien2SpriteOn),
                          .A3SpriteOn(Alien3SpriteOn),.A1dataout(A1dout),
                          .A2dataout(A2dout),.A3dataout(A3dout),.Pclk(PixCLK),.gameover(GameOver),
                          .i_reset(rst),.HitEnemy(HitEnemy),.o_resetnext(rstnext),.o_gameround(gameround));
                          
    // instantiate BeeSprite code
    wire ShipBulletSpriteOn;
    wire [7:0] shipBulletDataOut;
    bulletSprite BulletDisplay (.xx(x),.yy(y),.aactive(active), .beeX(beeX), .beeY(beeY),
                          .BulletSpriteOn(shipBulletSpriteOn),.dataout(shipBulletDataOut),
                          .gameover(GameOver),.i_reset(rst),
                          .Pclk(PixCLK), .fireButton(mouse_click_out),.HitEnemy(HitEnemy));
    
    
    // instantiate AlienSprites code
    wire MotherShipSpriteOn;
    wire [7:0] MSdout;
    wire [9:0] bossX, bossY;
    MotherShipSprite MSDisplay (.xx(x),.yy(y),.aactive(active),
                          .MSSpriteOn(MotherShipSpriteOn),.MSdataout(MSdout),
                          .Pclk(PixCLK),.gameover(GameOver),.i_reset(rst),.i_resetnext(rstnext),
                          .bossXOUT(bossX), .bossYOUT(bossY));
    
    wire bossBulletSpriteOn;
    wire [7:0] bossBulletDataOut;
    motherBulletSprite bossBullet (.xx(x),.yy(y),.aactive(active), .shipX(bossX), .shipY(bossY),
                          .BulletSpriteOn(bossBulletSpriteOn),.dataout(bossBulletDataOut),
                          .gameover(GameOver),.i_reset(rst),.i_resetnext(rstnext),
                          .Pclk(PixCLK),.i_gameround(gameround));
                      
    wire GOSpriteOn; // 1=on, 0=off
    wire [7:0] GOdout; // pixel value from Alien1.mem
    GameOVSprite GODisplay (.xx(x),.yy(y),.aactive(active),
                          .SpriteOn(GOSpriteOn),.GOdataout(GOdout),
                          .Pclk(PixCLK),.gameover(GameOver));
                          
  
    // load colour palette
    reg [7:0] palette [0:191]; // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0;
    initial begin
        $readmemh("pal24bit.mem", palette); // load 192 hex values into "palette"
    end
    
    // load colour palette
    reg [7:0] palette2 [0:191];
    initial begin
        $readmemh("plNewnew.mem", palette2);
    end
    
    reg [7:0] paletteGameOver [0:191];
    initial begin
        $readmemh("plGameover5.mem", paletteGameOver);
    end

    always @ (posedge PixCLK)
    begin
        if(rst == 1)begin
            GameOver <= 0;
        end
        if(rstnext == 1)begin
            GameOver <= 0;
        end
        if(btnU==1) begin
            GameOver <= 1;
            end
        if (active)
            begin
                if ((Alien3SpriteOn==1 && shipBulletSpriteOn==1)||
                    (Alien2SpriteOn==1 && shipBulletSpriteOn==1)||
                    (Alien1SpriteOn==1 && shipBulletSpriteOn==1))
                    begin
                        HitEnemy <= 1;
                    end
                else
                    begin
                        HitEnemy <= 0;
                    end
                if ((Alien3SpriteOn==1 && ShipSpriteOn==1)||
                    (Alien2SpriteOn==1 && ShipSpriteOn==1)||
                    (Alien1SpriteOn==1 && ShipSpriteOn==1)||
                    (bossBulletSpriteOn==1 && ShipSpriteOn==1))
                    begin
                        GameOver <= 1;
                    end
                if (GOSpriteOn==1)
                    begin
                        RED <= (paletteGameOver[(GOdout*3)])>>4;
                        GREEN <= (paletteGameOver[(GOdout*3)+1])>>4;
                        BLUE <= (paletteGameOver[(GOdout*3)+2])>>4;
                    end
                else if (MotherShipSpriteOn==1)
                    begin
                        RED <= (palette2[(MSdout*3)])>>4;
                        GREEN <= (palette2[(MSdout*3)+1])>>4;
                        BLUE <= (palette2[(MSdout*3)+2])>>4;
                    end
                else if (ShipSpriteOn==1)
                    begin
                        RED <= (palette2[(dout*3)])>>4;
                        GREEN <= (palette2[(dout*3)+1])>>4;
                        BLUE <= (palette2[(dout*3)+2])>>4;
                    end
                else if (Alien1SpriteOn==1)
                    begin
                        RED <= (palette2[(A1dout*3)])>>4;
                        GREEN <= (palette2[(A1dout*3)+1])>>4;
                        BLUE <= (palette2[(A1dout*3)+2])>>4;
                    end
                else if (Alien2SpriteOn==1)
                    begin
                        RED <= (palette2[(A2dout*3)])>>4;
                        GREEN <= (palette2[(A2dout*3)+1])>>4;
                        BLUE <= (palette2[(A2dout*3)+2])>>4;
                    end
                else if (Alien3SpriteOn==1)
                    begin
                        RED <= (palette2[(A3dout*3)])>>4;
                        GREEN <= (palette2[(A3dout*3)+1])>>4;
                        BLUE <= (palette2[(A3dout*3)+2])>>4;
                    end
                else if (shipBulletSpriteOn==1)
                    begin
                        RED <= (palette[(shipBulletDataOut*3)])>>4;
                        GREEN <= (palette[(shipBulletDataOut*3)+1])>>4;
                        BLUE <= (palette[(shipBulletDataOut*3)+2])>>4;
                    end
                else if (bossBulletSpriteOn==1)
                    begin
                        RED <= (palette[(bossBulletDataOut*3)])>>4;
                        GREEN <= (palette[(bossBulletDataOut*3)+1])>>4;
                        BLUE <= (palette[(bossBulletDataOut*3)+2])>>4;
                    end
                else
                    begin
                        RED <= (palette[(COL*3)])>>4;
                        GREEN <= (palette[(COL*3)+1])>>4;
                        BLUE <= (palette[(COL*3)+2])>>4;
                    end
            end
        else
                begin
                    RED <= 0;
                    GREEN <= 0;
                    BLUE <= 0;
                    
                end
    end
endmodule
