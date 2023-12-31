
module divide(clk,rst_n,clkout);
 
   input clk,rst_n;                       	//输入信号，频率为50MHz
   output clkout;                          	//输出信号，可以连接到LED观察分频的时钟
 
	reg[WIDTH-1:0] cnt_p,cnt_n;     				//cnt_p为上升沿触发时的计数器，cnt_n为下降沿触发时的计数器
	reg clk_p,clk_n;     							//clk_p为上升沿触发时分频时钟，clk_n为下降沿触发时分频时钟
 
	parameter WIDTH	= 3;             			//计数器的位数，计数的最大值为 2**WIDTH-1
	parameter N	= 5;             					//分频系数，请确保 N < 2**WIDTH-1，否则计数会溢出
 
	//上升沿触发时计数器的控制
	always @ (posedge clk or negedge rst_n)begin                   
		if(~rst_n)cnt_p<=0;
		else if(cnt_p==(N-1))cnt_p<=0;
		else cnt_p<=cnt_p+1;             		//计数器一直计数，当计数到N-1的时候清零，这是一个模N的计数器
	end
 
	//上升沿触发的分频时钟输出,如果N为奇数得到的时钟占空比不是50%；如果N为偶数得到的时钟占空比为50%
	always @ (posedge clk or negedge rst_n)begin
		if(~rst_n)clk_p<=0;
		else if(cnt_p<(N>>1))clk_p<=0;			//N>>1表示右移一位，相当于除以2去掉余数
		else clk_p<=1;               				//得到的分频时钟正周期比负周期多一个clk时钟
	end
 
   //下降沿触发时计数器的控制        	
	always @ (negedge clk or negedge rst_n)begin
		if(~rst_n)cnt_n<=0;
		else if(cnt_n==(N-1))cnt_n<=0;
		else cnt_n<=cnt_n+1;
	end
 
   //下降沿触发的分频时钟输出，和clk_p相差半个时钟
	always @ (negedge clk)begin
		if(~rst_n)clk_n<=0;
		else if(cnt_n<(N>>1))clk_n<=0;
		else clk_n<=1;                			//得到的分频时钟正周期比负周期多一个clk时钟
	end

	//当N=1时，直接输出clk
	//当N为偶数也就是N的最低位为0，N（0）=0，输出clk_p
	//当N为奇数也就是N最低位为1，N（0）=1，输出clk_p&clk_n。正周期多所以是相与
	assign clkout = (N==1)?clk:(N[0])?(clk_p&clk_n):clk_p;  
	
endmodule 
