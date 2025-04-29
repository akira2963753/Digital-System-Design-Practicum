module lab4_1( //Carry lock-ahead adder
	input [3:0]A,
	input [3:0]B,
	input C0,
	output [3:0]S,
	output C4
);
//Carry
	wire [3:0] P,G;
	wire [3:1] C;
	assign P=A^B;
	assign G=A&B;
	assign C[1] = G[0]|(P[0]&C0);
	assign C[2] = G[1]|(P[1]&C[1]);
	assign C[3] = G[2]|(P[2]&C[2]);
	assign C4 = G[3]|(P[3]&C[3]);
//Sum
	genvar i;
	generate
		for(i=0;i<=3;i=i+1) begin :adder
			if(i==0) sum_cal u1(P[0],C0,S[0]);
			else sum_cal u2(P[i],C[i],S[i]);
		end
	endgenerate
endmodule

module sum_cal(input P,input C,output S);
	assign S = P^C;
endmodule