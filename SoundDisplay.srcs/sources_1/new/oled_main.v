`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2020 19:36:26
// Design Name: 
// Module Name: oled_main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oled_main(input sixclock, input [15:0] sw , input [15:0] soundlevel, input [12:0] pixel_index, input up, down, left, right, reset, output reg [15:0] oled_data, output reg [10:0] wordscore = 0);
    wire [6:0] x;
    wire [6:0] y;
    wire [15:0] wordgamedata;
    wire [15:0] graphdata;
    reg [15:0] z = 0;
    reg [15:0] GREEN = 16'b0000011111100000;
    reg [15:0] YELLOW = 16'b1111111111100000;
    reg [15:0] PINK = 16'b1111100000011111;
    reg [15:0] RED = 16'b1111100000000000;
    reg [15:0] BLACK = 16'b0000000000000000;
    reg [15:0] WHITE = 16'b1111111111111111;
    reg [15:0] BLUE = 16'b0000000000011111;
    wire [10:0] wscore;
    
    coordinates coor(pixel_index, x , y);
    drawRectangle rect(sixclock,soundlevel, x, y,GREEN,YELLOW,RED,BLACK,WHITE, graphdata);
    wordGame word(sixclock, x,y,WHITE,GREEN,PINK,RED,BLACK,BLUE,up,down,left,right,reset,wordgamedata, wscore);
    always @ (posedge sixclock) begin
        if (sw[13] == 1) begin
            GREEN = 16'b0000011111111111; //Cyan
            YELLOW = 16'b1111111111111111; //White
            RED = 16'b1111100000011111; //Pink
            BLACK = 16'b0000000000011111; //Blue
            WHITE = 16'b1111100000000000; //Red
        end
        if (sw[12] == 1) begin
            GREEN = 16'b1111100000011111; //Pink
            YELLOW = 16'b1111100000000000; //Red
            RED = 16'b0000000000011111; //Blue
            BLACK = 16'b1111111111111111; //White
            WHITE = 16'b0000000000011111; //Blue
        end
        if (sw[13] == 0 && sw[12] == 0) begin
            GREEN = 16'b0000011111100000;
            YELLOW = 16'b1111111111100000;
            RED = 16'b1111100000000000;
            BLACK = 16'b0000000000000000;
            WHITE = 16'b1111111111111111;
        end
        //word game activated
        if (sw[1] == 1) begin
            oled_data <= wordgamedata;
            wordscore <= wscore;
        end
        else if (sw[1] == 0) begin
            //1 pixel border
            if ((x == 0 || x == 95) || (y==0 || y==63)) begin
                if(sw[14] == 0)
                    oled_data <= WHITE;
                else //turn off border
                    oled_data <= BLACK;
            end
            //3 pixel border
            else if (((x>= 1 && x <= 2) || (x >= 93 && x <= 94)) || ((y>= 1 && y <= 2) || (y>=61 && y <= 62))) begin
                if(sw[14] == 0 && sw[15] == 1)
                    oled_data <= WHITE;
                else //turn off border
                    oled_data <= BLACK;
            end
            //soundbar
            else if (x >= 42 && x <= 56 && y >= 10 && y <= 56)
                oled_data <= graphdata;
            //all other cases
            else
                oled_data <= BLACK;
        end
    end
endmodule
