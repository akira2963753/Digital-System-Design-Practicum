module lab7_3(
	input [7:0] in,
	output reg [3:0] units,
	output reg [3:0] tens,
	output reg [1:0] hunds,
	output reg [17:0] bcd
);
	
	integer i;
	always @(*) begin
		bcd = 18'b0;
		bcd[7:0] = in;
		for(i=0;i<8;i=i+1) begin
			bcd = bcd <<1;
			if(bcd[17:16]>=4'd5&&i<7) bcd[17:16] = bcd[17:16] + 4'd3;
			if(bcd[15:12]>=4'd5&&i<7) bcd[15:12] = bcd[15:12] + 4'd3;
			if(bcd[11:8]>=5&&i<7) bcd[11:8] = bcd[11:8] + 3;
		end
		units = bcd[11:8];
		tens = bcd[15:12];
		hunds = bcd[17:16];
	end
endmodule