module demux1_2(
input i,
input sel,
output [1:0]o
);

assign o[1]=i&sel;
assign o[0]=i&~(sel);

endmodule