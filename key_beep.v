module key_beep(
	input sys_clk,
	input rst_n,
	input [7:0]key,
	output reg beep
);

localparam BTN1     = 95556;	//按键音1  523.251Hz C5
localparam BTN2	  = 85131;	//按键音2  587.33Hz D5
localparam BTN3     = 75843;	//按键音3  659.255Hz E5
localparam BTN4     = 71586;	//按键音4  698.456HZ F5
localparam BTN5     = 63776;	//按键音5  783.991HZ G5
localparam BTN6     = 56818;	//按键音5  880HZ A6
localparam BTN7     = 50619;	//按键音5  987.767HZ B6
localparam BTN8     = 47778;	//按键音5  1046.502HZ C6
localparam FAN  	  = 1515151;//风扇噪音  33Hz

localparam DELAY	  = 2500000;//时延0.5s

//状态机
reg[21:0] beep_N = 22'b0;
reg[21:0] delay_N = DELAY;
always @(posedge sys_clk or negedge rst_n)begin
	if(!rst_n)begin
		beep_N <= 22'b0;
		delay_N <= DELAY;
	end else if(beep_N==FAN||delay_N==22'b0)begin
		case({key})
			8'b10000000: beep_N <= BTN1;
			8'b01000000: beep_N <= BTN2;
			8'b00100000: beep_N <= BTN3;
			8'b00010000: beep_N <= BTN4;
			8'b00001000: beep_N <= BTN5;
			8'b00000100: beep_N <= BTN6;
			8'b00000010: beep_N <= BTN7;
			8'b00000001: beep_N <= BTN8;
			default:		 beep_N <= FAN;
		endcase
		delay_N <= key!=8'b0 ? DELAY : 22'b0;
	end else delay_N <= delay_N-1;
end

//控制输出
reg out = 1'b0;
reg[21:0]cnt = 22'b0;
always @(posedge sys_clk or negedge rst_n)begin
	if(!rst_n)beep <= 1'b0;
	else beep <= out;
	if(!rst_n)begin
		out <= 0;
		cnt <= 22'b0;
	end else if(cnt==beep_N-1||delay_N==DELAY)begin	//当计数到达或开始延时
		out <= out+1;
		cnt <= 22'b0;
	end else cnt <= cnt+1;
end

endmodule
