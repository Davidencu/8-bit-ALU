`include"demux1_2.v"

module bus_demux #(parameter w=8)( //an 8-bit parametrizable bus demultiplexer, o1 is the output if sel=1 and o2 is the output if sel=0
	input [w-1:0]i,
	input sel,
	output [w-1:0]o1,
	output [w-1:0]o2
);

genvar index;
generate
	for(index=0;index<=w;index=index+1) begin: mux2_1
		demux1_2 demux2_inst(.i(i[index]), .sel(sel), .o({o1[index], o2[index]})); //generated using normal 2:1 demultiplexers
	end
endgenerate

endmodule

module bus_demux_tb();

parameter w=8;
reg [w-1:0]i;
reg sel;
wire [w-1:0]o1;
wire [w-1:0]o2;

bus_demux DUT_BUS_DEMUX(.i(i), .sel(sel), .o1(o1), .o2(o2));

initial begin
i=8'b10110101;
sel=0;
#100;
sel=1;
#100;
end

endmodule