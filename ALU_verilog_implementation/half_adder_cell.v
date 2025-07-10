module half_adder_cell(
input [1:0]i,
output sum, carry
);

assign sum=i[1]^i[0];
assign carry=i[1]&i[0];

endmodule