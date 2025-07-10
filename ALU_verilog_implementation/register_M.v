module register_M( //8 bit register, can perform only left shift for SRT-2 division
input load, //load the register
input [7:0]m, //signals entering the register at load
input lshift, //left shift the register
input left_shift_entry_wire,//signal that enters the register when doing left-shift
input clk, //clock signal
output [7:0]q, //output signal bus
output [7:0]not_q //inverted output signal bus
);

//wire [1:0]enc;
wire [8:0]d;

genvar i;
generate
	for(i=0;i<=8;i=i+1)
		begin: d_flip_flop
			d_flip_flop d_inst(.d(d[i]), .clk(clk), .q(q[i]), .not_q(not_q[i]));
		end
endgenerate

genvar j;
generate
	for(i=0;i<=8;i=i+1) //when doing left shift we select q[i-1], when doing load, we select m[i]
		begin: mux4_1
			if(i==0)
			mux4_1 mux4_inst4(.i({1'b0, 1'b0, m[i], q[i]}), .sel({lshift, load}), .o(d[i]));
			else
			mux4_1 mux4_inst6(.i({q[i-1], q[i-1], m[i], q[i]}), .sel({lshift, load}), .o(d[i]));
		end
endgenerate

endmodule

module register_M_tb();

reg load; //load signal
reg lshift; //left shift signal
reg left_shift_entry_wire; //at register M the left_shift_entry_wire is the 0 signal, we insert only digits of 0 at SRT radix-2 division
reg clk; //clock signal
reg [7:0]m; //signals entering the register at load
wire [7:0]q; //output signals of the register
wire [7:0]not_q;

register_M DUT_REGM(.load(load), .lshift(lshift), .left_shift_entry_wire(left_shift_entry_wire), .clk(clk), .m(m), .q(q), .not_q(not_q));

initial begin
clk=1'b0;
repeat (70) #(50) clk=~clk;
end

initial begin
m=8'b00010111;
load=1;
lshift=0;
left_shift_entry_wire=0;
#100;
m=8'b01101010;
#100;
load=0;
#100;
lshift=1;
left_shift_entry_wire=1;
#400;
lshift=0;
end

endmodule
