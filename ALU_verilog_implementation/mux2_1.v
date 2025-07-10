module mux2_1(input [1:0]i,input sel,output o);
	assign o = (sel&i[1]) | (~sel&i[0]);
endmodule