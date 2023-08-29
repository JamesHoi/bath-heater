
module segment(
	input clk,
	input rst_n,
	input[31:0] seg_data,	 //每一位的数码管数据
	input[7:0] seg_on,		 //每一位的数码管开关
	output reg[7:0] seg_led,
	output reg[7:0] cat		 //选通信号
);
	
	reg [3:0] cnt;				 // 计数
	reg [7:0] seg [15:0];
	initial begin
		cat <= 8'b0111_1111;
		cnt <= 3'b000;
		seg[0] = 8'h3f;       //对存储器中第一个数赋值9'b00_0011_1111,相当于共阴极接地，DP点变低不亮，7段显示数字  0
		seg[1] = 8'h06;       //7段显示数字  1
		seg[2] = 8'h5b;       //7段显示数字  2
		seg[3] = 8'h4f;       //7段显示数字  3
		seg[4] = 8'h66;       //7段显示数字  4
		seg[5] = 8'h6d;       //7段显示数字  5
		seg[6] = 8'h7d;       //7段显示数字  6
		seg[7] = 8'h07;       //7段显示数字  7
		seg[8] = 8'h7f;       //7段显示数字  8
		seg[9] = 8'h6f;       //7段显示数字  9
		seg[10] = 8'h77;		 //7段显示数字  A
		seg[11] = 8'h7c;		 //7段显示数字  b		
		seg[12] = 8'h39;		 //7段显示数字  C
		seg[13] = 8'h5e;		 //7段显示数字  d
		seg[14] = 8'h79;		 //7段显示数字  E
		seg[15] = 8'h71;		 //7段显示数字  F
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			cat <= 8'b0111_1111;
			cnt <= 3'b000;
			seg_led <= 8'h00;
		end else begin
			cat <= {cat[6:0],cat[7]};
			seg_led <= seg_on[cnt] ? seg[seg_data[(cnt+1)*4-1-:4]] : 8'h00;
			cnt <= cnt+1;
		end
	end

endmodule
