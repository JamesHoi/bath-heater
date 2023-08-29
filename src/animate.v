

module animate(
	input sys_clk,
	input clk_ani,
	input rst_n,
	input[7:0] key,
	output reg[63:0] matrix_r,
	output reg[63:0] matrix_g,
	output reg[31:0] seg_data,
	output reg[7:0] seg_on,
	output reg[15:0] led
);
	
	localparam AIR   	  = 3'd0 ;	//换气模式
   localparam AIR_HEAT = 3'd1 ;	//风暖模式
   localparam HEAT     = 3'd2 ;	//强暖模式
	localparam DRY      = 3'd3 ;	//干燥模式
	localparam STANDBY  = 3'd4 ;	//待机模式

	
	
	/*--------------------------- 按键控制开始 ---------------------------*/
	reg light = 1'b0;					//照明灯
	reg[2:0] mode = STANDBY;		//当前模式
	reg[2:0] new_mode = STANDBY;	//按键切换的新模式
	
	//按键对状态机的切换
	always @(posedge sys_clk or negedge rst_n)begin
		if(~rst_n) new_mode <= STANDBY;
		else begin
			case({key[6:0]})
				7'b1000000: new_mode <= (mode!=AIR 	  	 ? AIR 		: STANDBY);
				7'b0100000: new_mode <= (mode!=AIR_HEAT ? AIR_HEAT : STANDBY);
				7'b0010000: new_mode <= (mode!=HEAT	 	 ? HEAT 		: STANDBY);
				7'b0001000: new_mode <= (mode!=DRY		 ? DRY  		: STANDBY);
				default:		new_mode <= new_mode;
			endcase
		end
	end
	
	//照明灯切换
	always @(posedge sys_clk or negedge rst_n)begin
		if(~rst_n)light = 1'b0;
		else if(key[7])light <= ~light;
	end
	/*--------------------------- 按键控制结束 ---------------------------*/
	
	
	
	
	
	
	/*--------------------------- 动画控制开始 ---------------------------*/
	reg[1:0] cnt_ani = 2'b00;		//切换动画的计数
	reg[2:0] cnt_rst = 3'b100; 	//复位或启动时的计数
	reg[3:0] cnt_cls = 4'b0000; 	//关闭模式的计数
	reg[63:0] ani_r[0:3][0:3];
	reg[63:0] ani_g[0:3][0:3];
	
	initial begin
		ani_r[0][0] = 64'h0000_0000_0000_0000;		//二进制从左到右，需要把col设置引脚时，col[0]对应col7
		ani_r[1][0] = 64'h0000_0000_0000_0000;		//十六进制从左到右是从上到下
		ani_r[2][0] = 64'h0000_0000_0000_0000;
		ani_r[3][0] = 64'h0000_0000_0000_0000;
		ani_g[0][0] = 64'h87C6_E418_1827_63E1;
		ani_g[1][0] = 64'h0818_08FA_5F10_1810;
		ani_g[2][0] = 64'h87C6_E418_1827_63E1;
		ani_g[3][0] = 64'h0818_08FA_5F10_1810;
		
		ani_r[0][1] = 64'h0703_0508_10A0_C0E0;
		ani_r[1][1] = 64'h0000_40F2_4F02_0000;
		ani_r[2][1] = 64'hE0C0_A010_0805_0307;
		ani_r[3][1] = 64'h081C_0808_1010_3810;
		ani_g[0][1] = 64'hE0C0_A010_0805_0307;
		ani_g[1][1] = 64'h081C_0808_1010_3810;
		ani_g[2][1] = 64'h0703_0508_10A0_C0E0;
		ani_g[3][1] = 64'h0000_00F2_4F02_0000;
		
		ani_r[0][2] = 64'hE7C3_A518_18A5_C3E7;
		ani_r[1][2] = 64'h081C_48FA_5F12_3810;
		ani_r[2][2] = 64'hE7C3_A518_18A5_C3E7;
		ani_r[3][2] = 64'h081C_48FA_5F12_3810;
		ani_g[0][2] = 64'hE0C0_A010_0805_0307;
		ani_g[1][2] = 64'h081C_0808_1010_3810;
		ani_g[2][2] = 64'h0703_0508_10A0_C0E0;
		ani_g[3][2] = 64'h0000_40F2_4F02_0000;
		
		ani_r[0][3] = 64'h80C0_E010_0807_0301;
		ani_r[1][3] = 64'h0818_0808_1010_1810;
		ani_r[2][3] = 64'h0706_0408_1020_60E0;
		ani_r[3][3] = 64'h0000_00F2_4F00_0000;
		ani_g[0][3] = 64'h87C6_E418_1827_63E1;
		ani_g[1][3] = 64'h0818_08FA_5F10_1810;
		ani_g[2][3] = 64'h87C6_E418_1827_63E1;
		ani_g[3][3] = 64'h0818_08FA_5F10_1810;
	end
	
	//状态机1
	always @(posedge clk_ani or negedge rst_n)begin
		if(~rst_n)begin
			cnt_ani <= 2'b00;
			cnt_rst <= 3'b100;
		end else begin
			if(new_mode == STANDBY & mode != STANDBY)begin			//延时秒数
				case(mode)
					AIR:		cnt_cls <= 4'b0000;
					AIR_HEAT:cnt_cls <= cnt_cls==4'b0000 ? 4'b0101 : cnt_cls-1; //2Hz 2秒
					HEAT: 	cnt_cls <= cnt_cls==4'b0000 ? 4'b1001 : cnt_cls-1; //2Hz 4秒
					DRY:		cnt_cls <= 4'b0000;
				endcase
			end else cnt_cls <= cnt_cls!=4'b0000 ? cnt_cls-1 : 4'b0000;
			cnt_rst <= cnt_rst != 3'b000 ? cnt_rst-1 : 3'b000;
			cnt_ani <= mode != STANDBY ? cnt_ani+1 : 2'b00;
		end
	end
	
	//状态机2
	always @(posedge sys_clk or negedge rst_n)begin
		if(~rst_n)mode <= STANDBY;
		else if(new_mode == STANDBY & mode != STANDBY)begin			//延时秒数
			mode <= (mode==AIR||mode==DRY)||cnt_cls==4'b0001 ? new_mode : mode; //延时切换模式
		end else mode <= new_mode;
	end
	
	//输出
	always @(posedge sys_clk or negedge rst_n)begin
		if(~rst_n)begin //复位
			matrix_r <= 64'h0000_0000_0000_0000;
			matrix_g <= 64'h0000_0000_0000_0000;
			seg_data <= 32'h0000_0000;
			seg_on <= 8'b0000_0000;
			led <= 16'h0000;
		end else if(cnt_rst != 3'b000)begin	//启动动画
			matrix_r <= cnt_rst%2==0 ? 64'hFFFF_FFFF_FFFF_FFFF : 64'h0000_0000_0000_0000;
			matrix_g <= cnt_rst%2==1 ? 64'hFFFF_FFFF_FFFF_FFFF : 64'h0000_0000_0000_0000;
			seg_data <= 32'h8888_8888;
			seg_on <= cnt_rst%2==0 ? 8'b1111_1111 : 8'b0000_0000;	//数码管开关
			led <= cnt_rst%2==0 ? 16'hFFFF : 16'h0000;
		end else begin //动画显示
			matrix_r <= mode != STANDBY ? ani_r[cnt_ani][mode] : 64'h0000_0000_0000_0000;
			matrix_g <= mode != STANDBY ? ani_g[cnt_ani][mode] : 64'h0000_0000_0000_0000;
			seg_data <= {8'h00,1'b0,cnt_cls>>1,20'h0000};			//关闭模式显示倒计时时间
			seg_on <= cnt_cls == 4'b0000 ? 8'b0000_0000 : 8'b0010_0000;
			led <= {9'h00,light,6'h00};									//保持照明灯
		end
	end
	/*--------------------------- 动画控制结束 ---------------------------*/
	
endmodule
