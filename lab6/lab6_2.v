module lab6_2(
	input clk,
	output reg x,
	output reg y,
	output reg z
);
	reg [1:0] counter = 2'b00;
	initial {z,y,x} = 3'b100;
	always @(posedge clk) begin
		if({{z,y,x} == 3'b111||{z,y,x}==3'b001}&&{counter!=3}) begin
			{z,y,x} <= 3'b001;
			counter <= counter + 2'b01;
		end
		else begin
			{y,x} <= {z,y,x} >> 1;
			z <= ~x;
			counter <= 2'b0;
		end 
		if({z,y,x} == 3'b000) begin
				{z,y,x} <= 3'b100;
		end
		else;
	end
endmodule