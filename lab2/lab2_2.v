module lab2_2(
	input [1:0] A,
	input [1:0] B,
	output [3:0] S
);
	wire w1,w2,w3,C;
	assign S[0] = A[0]*B[0];
	assign w1 = A[0]*B[1];
	assign w2 = A[1]*B[0];
	HA HA1(w1,w2,S[1],C);
	assign w3 = A[1]*B[1];
	HA HA2(C,w3,S[2],S[3]);
endmodule

module HA(input A,input B,output S,output C);
	assign {C,S} = A+B;
endmodule