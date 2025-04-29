module lab7_1(
	input clk,
	input in,
	input rst,
	output reg out,
	output reg [1:0] out_state
);
	parameter [1:0] s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
	reg [1:0] next_state;
	
	always @(*)begin
		if(rst==1'b0) 
			out_state <= 2'b00;
		else 
			out_state <= next_state;
	end
	always @(posedge clk)begin
		case(out_state)
			s0:begin
				if(in==1'b0) begin
					next_state <= s0;
					out <= 1'b0;
				end
				else begin
					next_state <= s1;
					out <= 1'b0;
				end
			end
			s1:begin
				if(in==1'b0) begin
					next_state <= s0;
					out <= 1'b1;
				end
				else begin
					next_state <= s3;
					out <= 1'b0;
				end
			end
			s2:begin
				if(in==1'b0) begin
					next_state <= s0;
					out <= 1'b1;
				end
				else begin
					next_state <= s2;
					out <= 1'b0;
				end
			end
			s3:begin
				if(in==1'b0) begin
					next_state <= s0;
					out <= 1'b1;
				end
				else begin
					next_state <= s2;
					out <= 1'b0;
				end
			end
		endcase
		if(rst==1'b0)begin 
			next_state <= s0;
		end
	end
endmodule