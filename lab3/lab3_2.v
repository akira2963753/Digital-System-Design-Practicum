module lab3_2(
	input [3:0] in,
	input [1:0] sel,
	input en,
	output reg out
);
always @(*) begin
	if(en) begin
		case(sel)
		2'b00: out = in[0];
		2'b01: out = in[1];
		2'b10: out = in[2];
		2'b11: out = in[3];
		endcase
	end
	else begin
		out = 1'bz;
	end
end


endmodule