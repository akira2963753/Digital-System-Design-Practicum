module lab3_1(
	input [31:0] in,
	input [4:0] sel,
	output out
);
	assign out = in[sel];
endmodule