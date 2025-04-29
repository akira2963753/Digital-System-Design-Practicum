module lab6_3(
	input clear,
	input clk,
	input s_in,
	input shift_ctrl,
	output [3:0] p_out1,
	output [3:0] p_out2,
	output DFF_Q,
	output DFF_clk 
);
	//output DFF_Q;
	wire FA_S,FA_C;
	assign DFF_clk = shift_ctrl&clk;
	SR s0(FA_S,shift_ctrl,clk,p_out1);
	SR s1(s_in,shift_ctrl,clk,p_out2);
	D_FF d0(DFF_clk,clear,FA_C,DFF_Q);
	FA f0(p_out1[0],p_out2[0],DFF_Q,FA_S,FA_C);

endmodule

module D_FF(input clk,input clear,input D,output reg  Q); //DFF
	
		always @(posedge clk)begin
		if(!clear) Q <= 1'b0;
		else Q <= D; 
end
		
endmodule

module FA(input x,input y,input z,output s,output c); //Full-Adder
	assign {c,s} = x + y + z;
endmodule

module SR(input si,input sc,input clk,output reg [3:0] so); //Shift Register
	always @(posedge clk) begin
		if(sc) begin //shiftcontrol = 1 can shift
			if(si) begin 
				so[3:0] = {1'b1, so[3:1]}; //+1	 
			end
			else begin
				so[3:0] = {1'b0, so[3:1]}; //+0
			end
		end
		else;
	end
endmodule