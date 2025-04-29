module lab4_2(
	input set,
	input reset,
	input clk,
	input J,
	input K,
	output reg Q
);
	always @(negedge clk) begin
		if(set&&reset) begin
			Q <= ~Q;
		end
		else if(reset) begin
			Q <= 1'b0;
		end
		else if(set) begin
			Q <= 1'b1;
		end
		else begin
			case({J,K})
				2'b00 : Q <= Q;
				2'b01 : Q <= 1'b0;
				2'b10 : Q <= 1'b1;
				2'b11 : Q <= ~Q;
			endcase
		end
end
endmodule