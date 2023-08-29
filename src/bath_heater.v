/*
Author: James Hoi
Date: 2021.12.02
Description: 数电大实验实验一题目：浴霸
*/

module bath_heater(
	input clk,				//时钟为50MHz
	input rst,				//SW6重置电路
	input[7:0] btn,		//BTN7~BTN0
	input[3:0] keyboard_row,	//4x4键盘行
	output[3:0] keyboard_col,	//4x4键盘列
	output[15:0] led,		//灯LD15~LD0
	output[7:0] led_r,	//红色行
	output[7:0] led_g,	//绿色行
	output[7:0] led_d,	//共地，控制列
	output[7:0] seg_led,	//数码管
	output[7:0] seg_cat,	//选择数码管
	output beep				//蜂鸣器
);

	wire clk_led; 						//扫描led时钟
	wire clk_ani; 						//动画时钟
	wire clk_seg; 						//扫描数码管时钟
	wire clk_keyboard;				//扫描4x4键盘时钟
	wire[63:0] matrix_r;				//当前状态动画红色矩阵值
	wire[63:0] matrix_g;				//当前状态动画蓝色矩阵值
	wire[7:0] key_pulse;				//消抖后的按键脉冲
	wire[15:0] keyboard_pulse;		//消抖后的4x4键盘脉冲
	wire[31:0] seg_data;				//数码管显示的值
	wire[7:0] seg_on;					//数码管的开关
	wire[7:0] key = keyboard_pulse[7:0]|key_pulse; //4x4键盘按键和正常按键
	
	
	//实例化按键蜂鸣器模块
	key_beep b3(
	.sys_clk(clk),
	.rst_n(rst),
	.key(key),
	.beep(beep)
	);
	
	
	//实例化按键消抖
	debounce #(8) d1(
	.clk(clk),
	.rst(rst),
	.key(btn),
	.key_pulse(key_pulse)
	);
	
	
	//实例化4x4键盘并消抖
	keyboard k1(
	.sys_clk(clk),
	.rst_n(rst),
	.row(keyboard_row),
	.col(keyboard_col),
	.pulse(keyboard_pulse)
	);	
	
	
	//产生一个1kHz时钟信号，N=50000
	//50000000/50000=1kHz 延时1ms
	//分频给数码管时钟
	divide #(.WIDTH(32),.N(50000)) u1(
	.clk(clk),
	.rst_n(rst),
	.clkout(clk_seg)
	);
	//例化数码管组
	segment s1(
	.clk(clk_seg),
	.rst_n(rst),
	.seg_data(seg_data),
	.seg_led(seg_led),
	.seg_on(seg_on),
	.cat(seg_cat)
	);
	
	
	//产生一个10kHz时钟信号，N=5000
	//50000000/5000=10kHz
	//分频给LED扫描时钟
	divide #(.WIDTH(32),.N(5000)) u2(
	.clk(clk),
	.rst_n(rst),
	.clkout(clk_led)
	);
	//例化矩阵LED
	led_matrix l1(
	.clk(clk_led),
	.rst_n(rst),
	.matrix_r(matrix_r),
	.matrix_g(matrix_g),
	.row(led_d),
	.col_r(led_r),
	.col_g(led_g),
	);
	
	
	//产生2Hz时钟信号,N=25000000
	//仿真设置为2MHz,N=25
	//分频给动画时钟
	divide #(.WIDTH(32),.N(25000000)) u3(
	.clk(clk),
	.rst_n(rst),
	.clkout(clk_ani)
	);
	//例化LED动画模块
	animate a1(
	.sys_clk(clk),
	.clk_ani(clk_ani),
	.rst_n(rst),
	.key(key),
	.matrix_r(matrix_r),
	.matrix_g(matrix_g),
	.seg_data(seg_data),
	.seg_on(seg_on),
	.led(led)
	);

endmodule
