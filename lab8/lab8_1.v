module lab8_1(
	input add1,
	input add10,
	input sub1,
	input sub10,
	input clk,
	output [7:0] seg1,
	output [7:0] seg2
);
	
	reg [6:0] count ;
	wire [6:0] units ;
	wire [6:0] hundreds ;
	assign hundreds = count/7'd10;
	assign units = count%7'd10;
	seven_seg u0(units,seg1);
	seven_seg u1(hundreds,seg2);
	always @(posedge clk) begin
		if(add1) begin
			if(count<7'd99) count = count + 7'd1;
			else count = 7'd99;
		end
		else if(add10) begin
			if(count<=7'd89) count = count + 7'd10;
			else count = 7'd99;
		end
		else if(sub1) begin
			if(count>7'd0) count = count - 7'd1;
			else count = 7'd0;
		end
		else if(sub10) begin
			if(count>=7'd10) count = count - 7'd10;
			else count = 7'd0;
		end
		else;
		
	end
	
endmodule

module seven_seg(
	input [6:0] in,
	output reg [7:0] out
);
	always @(*) begin
		case(in)
			7'd0: out = 8'b11000000;
			7'd1: out = 8'b11111001;
			7'd2: out = 8'b10100100;
			7'd3: out = 8'b10110000;
			7'd4: out = 8'b10011001;
			7'd5: out = 8'b10010010;
			7'd6: out = 8'b10000010;
			7'd7: out = 8'b11111000;
			7'd8: out = 8'b10000000;
			7'd9: out = 8'b10010000;
			default : out = 8'b11000000;
		endcase
	end
endmodule