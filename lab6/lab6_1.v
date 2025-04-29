module lab6_1(
	input clk,
	input [7:0] in,
	input [1:0] sel,
	output reg [7:0] out
);
	always @(posedge clk) begin
		case(sel)
			2'b00: out <= in;
			2'b01: out <= out>>3;
			2'b10: out <= out>>2;
			2'b11: out <= out>>1;
		endcase
	end
endmodule