module lab5_1( 
	input [3:0] in,
	input count,
	input load,
	input clear,
	input clk,
	output reg [3:0] out
);
	always @(posedge clk or posedge clear) begin
		if(clear) begin
			out <= 4'b0000; //clear out
		end
		else if(load) begin //load in
			out <= in;
		end
		else if(count) begin //count
			if(out==4'b1111) begin
				out <= 4'b0000;
			end
			else begin
			out <= out + 4'b0001;
			end
		end
		else;
	end
endmodule