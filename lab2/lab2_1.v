module lab2_1(X1,X2,X3,X4,g,f,h);
	input X1,X2,X3,X4;
	output g,f,h;
	wire w1,w2,w3,w4;
	assign w1 = X1*X2;
	assign w2 = w1+w1;
	assign g = w2;
	assign w3 = X3+X4;
	assign w4 = w3*w3;
	assign h = w4;
	assign f = w2*w4;


endmodule