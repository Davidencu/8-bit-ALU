`include"mux2_1.v"

module bus_mux #(parameter w=8)(
	input [w-1:0]i1,
	input [w-1:0]i2,
	input sel,
	output [w-1:0]o
);

genvar index;
generate
	for(index=0;index<=w;index=index+1) begin: mux2_1
		mux2_1 mux2_inst(.i({i1[index], i2[index]}), .sel(sel), .o(o[index]));
	end
endgenerate

endmodule

module bus_mux_tb();

parameter w=8;
reg [w-1:0]i1;
reg [w-1:0]i2;
reg sel;
wire [w-1:0]o;

bus_mux DUT_BUS_MUX(.i1(i1), .i2(i2), .sel(sel), .o(o));

initial begin
i1=8'b10110101;
i2=8'b00011010;
sel=0;
#100;
sel=1;
#100;
end

endmodule