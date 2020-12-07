`timescale 1ns / 1ps

module BeeSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg BSpriteOn, // 1=on, 0=off
    output wire [7:0] dataout, // 8 bit pixel value from Bee.mem
    input wire BR, // right button
    input wire BL, // left button
    input wire gameover,
    input wire i_reset,
    input wire Pclk, // 25MHz pixel clock
    output reg[9:0] beeXOUT,
    output reg[9:0] beeYOUT,
    
    input wire [8:0] xm,
    input wire m_done_tick
    );

    wire sx = xm[8];
    wire [8:0] ndx = sx ? {1'b0,~xm[7:0]}+1 : {1'b0,xm[7:0]};
    
    // instantiate BeeRom code
    reg [9:0] address; // 2^10 or 1024, need 34 x 27 = 918
    BeeRom BeeVRom (.i_addr(address),.i_clk2(Pclk),.o_data(dataout));
            
    // setup character positions and sizes
    reg [9:0] BeeX = 297; // Bee X start position
    reg [8:0] BeeY = 433; // Bee Y start position
    localparam BeeWidth = 28; // Bee width in pixels
    localparam BeeHeight = 16; // Bee height in pixels
    localparam ShipSpeed = 5;
    always @ (posedge Pclk)
    begin
        if(i_reset==1) begin
                BeeX <= 297;
                BeeY <= 433;
            end
        else if (xx==639 && yy==479)
            begin // check for left or right button pressed
//                if ((BR == 1 ||  > 0) && BeeX<640-BeeWidth-2)
//                    BeeX<=BeeX+ShipSpeed;
//                if ((BL == 1 || xm < 0) && BeeX>2)
//                    BeeX<=BeeX-ShipSpeed;
                  BeeX <= (ndx > 2 && ndx < 100) ? (sx ? (BeeX>2+ndx ? BeeX - ndx : 2) 
			                 : (BeeX < 640-BeeWidth-2-ndx) ? BeeX+ndx : 640-BeeWidth-2) : BeeX;
            end    
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
                if (xx==BeeX-1 && yy==BeeY && gameover == 0)
                    begin
                        address <= 0;
                        BSpriteOn <=1;
                    end
                if ((xx>BeeX-1) && (xx<BeeX+BeeWidth) && (yy>BeeY-1) && (yy<BeeY+BeeHeight) && gameover == 0)
                    begin
                        address <= address + 1;
                        BSpriteOn <=1;
                    end
                else
                    BSpriteOn <=0;
            end
        beeXOUT <= BeeX;
        beeYOUT <= BeeY;
    end
endmodule