`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2020 01:06:56
// Design Name: 
// Module Name: blue_color
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


module blue_color(input clk6p25m, input [6:0] x, input [6:0] y, input [15:0] WHITE,GREEN,PINK,RED,BLACK,output reg [15:0] blue_data);
    wire [15:0] B_data;
    wire [15:0] L_data;
    wire [15:0] U_data;
    wire [15:0] E_data;
    reg [6:0] x1 =0;
    reg [6:0] y1 =0;
    reg [21:0] counter = 0;

    letters b(clk6p25m, x, y, x1, x1+4, y1, y1+9, 2, WHITE,GREEN,PINK,RED,BLACK, B_data); //b
    letters l(clk6p25m, x, y, x1+7, x1+11, y1, y1+9, 12, WHITE,GREEN,PINK,RED,BLACK, L_data); //L
    letters u(clk6p25m, x, y, x1+14, x1+18, y1, y1+9, 21, WHITE,GREEN,PINK,RED,BLACK, U_data); //U
    letters e(clk6p25m, x, y, x1+21, x1+25, y1, y1+9, 5, WHITE,GREEN,PINK,RED,BLACK, E_data); //E

    always @ (posedge clk6p25m) begin
        counter <= counter +1;
        x1 <= (counter == 0)? {x1[5:0], ~(x1[6] ^ x1[5])} % 70 : x1;
        y1 <= (counter == 0)? {y1[5:0], ~(y1[6] ^ y1[5])} % 54: y1;
        if (x>=x1 && x<=x1+4 && y>=y1 && y<=y1+9)
            blue_data <= B_data;
        else if (x>=x1+7 && x<=x1+11 && y>=y1 && y<=y1+9)
            blue_data <= L_data;
        else if (x>=x1+14 && x<=x1+18 && y>=y1 && y<=y1+9)
            blue_data <= U_data;
        else if (x>=x1+21 && x<=x1+25 && y>=y1 && y<=y1+9)
            blue_data <= E_data;
        else
            blue_data <= BLACK;
        end
endmodule
