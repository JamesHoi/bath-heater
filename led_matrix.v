
module led_matrix(
	input clk,
	input rst_n,
	input[63:0] matrix_r,	//输入矩阵,红色
	input[63:0] matrix_g,	//输入矩阵,绿色
	output reg[7:0] col_r,  // 列,红色
	output reg[7:0] col_g,	// 列,绿色
	output reg[7:0] row 		// 行
);
	
	reg [3:0] cnt;				// 计数
	initial begin
		row <= 8'b0111_1111;
		col_r <= 8'h00;
		col_g <= 8'h00;
		cnt <= 3'b000;
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			row <= 8'b0111_1111;
			col_r <= 8'h00;
			col_g <= 8'h00;
			cnt <= 3'b000;
		end else begin
			row <= {row[6:0],row[7]};
			col_r <= matrix_r[(cnt+1)*8-1-:8];
			col_g <= matrix_g[(cnt+1)*8-1-:8];
			cnt <= cnt+1;
		end
	end
	
endmodule
