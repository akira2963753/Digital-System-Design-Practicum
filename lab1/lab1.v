module lab1(
	output X,
	input A,
	input B,
	input C
);
	wire D,E;
	and g1(D,A,B);
	and g2(E,A,C);
	or g3(X,D,E);
endmodule
