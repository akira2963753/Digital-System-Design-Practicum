module lab9_1(
	input clk,
	output reg [7:0] row,
	output reg [7:0] col
);
	reg [2:0] state,next_state;
	always @(posedge clk) begin
		state <= next_state;
	end
	always @(*) begin
		case(state)
			3'b000:begin
				next_state <= 3'b001;
				row = 8'b00000001;
				col = 8'b00011100;
			end
			3'b001:begin
				next_state <= 3'b010;
				row = 8'b00000010;
				col = 8'b00011100;
			end
			3'b010:begin
				next_state <= 3'b011;
				row = 8'b00000100;
				col = 8'b00011100;
			end
			3'b011:begin
				next_state <= 3'b100;
				row = 8'b00001000;
				col = 8'b00001000;
			end
			3'b100:begin
				next_state <= 3'b101;
				row = 8'b00010000;
				col = 8'b00011100;
			end
			3'b101:begin
				next_state <= 3'b110;
				row = 8'b00100000;
				col = 8'b00101010;		
			end
			3'b110:begin
				next_state <= 3'b111;
				row = 8'b01000000;
				col = 8'b00010100;		
			end
			3'b111:begin
				next_state <= 3'b000;	
				row = 8'b10000000;
				col = 8'b00110110;	
			end
			default: next_state <= 3'b000;
		endcase
	end
endmodule