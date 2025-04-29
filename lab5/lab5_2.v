module lab5_2(
	input clk,
	input rst,
	output reg [3:0] out = 4'b1010, //inital to 1010
	output reg f_out
);
	always @(posedge clk) begin
		if(rst==1'b0) begin
			out = 4'b1010;
			f_out <= 1'b0;
		end
		else begin
			if(out==4'b0001) begin //return 10110 and not f_out
				f_out <= ~f_out; 
				out <= 4'b1010;
			end
			else begin
				out <= out - 4'b0001; //count
			end
		end
	end
endmodule

