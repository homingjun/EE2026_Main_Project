`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M, TUESDAY P.M, WEDNESDAY P.M, THURSDAY A.M., THURSDAY P.M
//
//  STUDENT A NAME: 
//  STUDENT A MATRICULATION NUMBER: 
//
//  STUDENT B NAME: 
//  STUDENT B MATRICULATION NUMBER: 
//
//////////////////////////////////////////////////////////////////////////////////

module Top_Student (
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    // Delete this comment and include other inputs and outputs here
    input [15:0] sw,
    output reg [3:0]an = 0,
    output reg [7:0]seg = 0,
    input CLK100MHZ,
    input mid_button, up_button, down_button, left_button, right_button,
    output rgb_cs,rgb_sdin,rgb_sclk,rgb_d_cn,rgb_resn,rgb_vccen,rgb_pmoden,
    output reg [15:0]led
    );
    
    wire [15:0] oled_data;
    wire sixclock, reset, clk20k, clk2, clk381, clkp5 , clk1 , game2clear , clk100k;
    wire up, down, left, right;
    wire [11:0] my_mic_data;
    wire [12:0] pixel_index;
    reg [15:0] soundlevel;
    wire [16:0] barclock;
    reg [11:0] copy_of_mic = 0;
    reg [11:0]max = 0;
    reg [2:0]display_state = 0;
    wire [15:0]peak;
    wire [7:0]segs0 , segs1, segs2 , segs3;
    wire [10:0] wordscore;
    wire [15:0] balloon_timer;
    wire [7:0] balloon_segs0 , balloon_segs1, balloon_segs2 , balloon_segs3;
    wire [4:0]peak_count;
    //Clocks
    clock_divider clk(CLK100MHZ , 2499 , clk20k);
    clock_divider clk6p25m(CLK100MHZ, 8 , sixclock);
    clock_divider clk2hz(CLK100MHZ , 24999999 ,clk2);
    clock_divider clk381hz(CLK100MHZ , 130 , clk381);
    clock_divider clk1hz(CLK100MHZ , 49_999_999 , clk1);
    clock_divider clk100khz(CLK100MHZ , 499 , clk100k);
    
    //Buttons
    debounce midf(mid_button,CLK100MHZ,reset);
    debounce upf(up_button,CLK100MHZ,up);
    debounce downf(down_button,CLK100MHZ,down);
    debounce leftf(left_button,CLK100MHZ,left);
    debounce rightf(right_button,CLK100MHZ,right);
    
    Oled_Display oled(.clk(sixclock), .reset(reset),.pixel_index(pixel_index),
    .pixel_data(oled_data), .cs(rgb_cs), .sdin(rgb_sdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
      .pmoden(rgb_pmoden));
    Audio_Capture CaptAudio(.CLK(CLK100MHZ),.cs(clk20k), .MISO(J_MIC3_Pin3), .clk_samp(J_MIC3_Pin1),.sclk(J_MIC3_Pin4),.sample(my_mic_data) );
    amplitude_mode amp(.clk381(clk381), .clk20k(clk20k), .clk2(clk2),  .my_mic_data(my_mic_data)  , .led_state(peak), .segs0(segs0) , .segs1(segs1) ,.segs2(segs2), .segs3(segs3),  .countA(peak_count) );
    
    oled_main display(CLK100MHZ, sixclock, sw , soundlevel, pixel_index, up, down, left, right, reset, oled_data, wordscore);
    balloon_game gametwo( .left_button(left) , .sw(sw[8]) ,.slow_clock(clk1),  .fast_clock(clk20k) ,  .countdown_clock(clk1),.timer(balloon_timer) , .segs0(balloon_segs0) , .segs1(balloon_segs1) ,.segs2(balloon_segs2) , .segs3(balloon_segs3),  .right_button(right) , .peak_count(peak_count));
/*
    always @ (posedge sixclock) begin
        soundlevel <= 16'b1111111111111111;
    end
*/
   assign game2clear = (sw[8] == 1) ? 0 : 1;
   
    always @  (posedge sixclock)
    begin
        led <= (sw[8] == 1) ? balloon_timer :((sw[0] == 1) ? my_mic_data:peak); //replace 0 with amplitude stud;
    end
    always @ (posedge clk381)
    begin
        if(sw[0] == 1)
            display_state  = 0;
        else
            display_state = display_state + 1;
        case(display_state)
        0:
        begin
            an <= 4'b1110;
            seg <= (sw[8] == 1) ? balloon_segs0 :segs0;
        end
        1:
        begin
            an <= 4'b1101;
            seg <= (sw[8] == 1) ? balloon_segs1 : segs1;
            display_state <= (sw[8]== 0)?3:display_state;
        end
        2:
        begin
            an <= 4'b1011;
            seg <= (sw[8] == 1)? balloon_segs2 : 8'b1111_1111;
        end
        3:
        begin
             an <= 4'b0111;
             seg <= (sw[8] == 1) ? balloon_segs3 : 8'b1111_1111;
        end
        default:
            an <= 4'b1111;
        endcase    
    end
    always @ (posedge sixclock) begin
        soundlevel <= led;
        if (sw[11] == 0)
            copy_of_mic <= led;
        //Freeze volume bar
        if (sw[11] == 1)
            soundlevel <= copy_of_mic;
        //Hide volume bar
        if (sw[10] == 1) begin
            soundlevel <= 0;
        end
    end
/*
    always@(posedge sixclock)
    begin
        led = (sw[0] == 1) ? my_mic_data:0;
        soundlevel <= my_mic_data;
        if (sw[11] == 0)
            copy_of_mic <= my_mic_data;
        //Freeze volume bar
        if (sw[11] == 1)
            soundlevel <= copy_of_mic;
        //Hide volume bar
        if (sw[10] == 1) begin
            soundlevel <= 0;
        end
    end
*/
endmodule
