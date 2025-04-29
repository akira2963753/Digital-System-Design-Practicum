module lab4_3(
	input [3:0] D_in,
	input load,
	input clk,
	input rst,
	output reg [3:0] D_out
);
	always @(posedge clk or negedge rst) begin
		if(rst==1'b0) begin
			D_out <= 4'b0000;
		end
		else if(load)begin
			D_out <= D_in;
		end
		else begin
			D_out <= D_out;
		end
	end
endmodule