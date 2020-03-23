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
    input sw,
    input CLK100MHZ,
    input mid_button,
    output reg [3:0]an = 0,
    output reg [7:0]seg = 0,
    output rgb_cs,rgb_sdin,rgb_sclk,rgb_d_cn,rgb_resn,rgb_vccen,rgb_pmoden,
    output reg [15:0]led
    );
    reg [11:0]max = 0;
    reg [2:0]display_state = 0;
    reg [15:0] oled_data = 16'h07E0;
    wire sixclock, reset, clk20k , clk2, clk381;
    wire [11:0]my_mic_data;
    wire [15:0]led_state;
    wire [7:0]segs0 , segs1;
    
    clock_divider clk20khz(CLK100MHZ , 2499 , clk20k);
    clock_divider clk6p25m(CLK100MHZ,8,sixclock);
    clock_divider clk2hz(CLK100MHZ , 12499999 ,clk2);
    clock_divider clk381hz(CLK100MHZ , 130 , clk381);
    debounce deboun(mid_button,CLK100MHZ,reset);
    Oled_Display oled(.clk(sixclock), .reset(reset),
    .pixel_data(oled_data), .cs(rgb_cs), .sdin(rgb_sdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
      .pmoden(rgb_pmoden));
    Audio_Capture CaptAudio(.CLK(CLK100MHZ),.cs(clk20k), .MISO(J_MIC3_Pin3), .clk_samp(J_MIC3_Pin1),.sclk(J_MIC3_Pin4),.sample(my_mic_data) );
    anplitude_mode amp(.CLK100MHZ(CLK100MHZ), .clk2(clk2),  .my_mic_data(my_mic_data)  , .led_state(led_state), .segs0(segs0) , .segs1(segs1)  );

    // Delete this comment and write your codes and instantiations here
    //Add in switching off the led
    always@(posedge CLK100MHZ, posedge clk381)
    begin
        led = (sw == 1) ? my_mic_data:(led_state); //replace 0 with amplitude studd;
        oled_data = my_mic_data[11:7];
        if (clk381== 1)
        begin
            if(sw == 1)
                display_state  = 0;
            else
                display_state <= display_state + 1;
            case(display_state)
            0:
            begin
                an <= 4'b1111;
                seg <= 8'b1111_1111;
            end
            1:
            begin
                an <= 4'b1110;
                seg <= segs0;
            end
            2:
            begin
                an <= 4'b1101;
                seg <= segs1;
            end
            3:
            begin
             an <= 4'b1111;
             seg <= 8'b1111_1111;
             display_state <= 0;
            end
      
            endcase  
        end  
     end
endmodule
