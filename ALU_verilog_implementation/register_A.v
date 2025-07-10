`include"mux2_1.v"
`include"mux4_1.v"
`include"encoder4_2.v"


module register_A(
input load, //load the register
input rshift, //right shift
input lshift, //left shift
input a7_mem, //used for specifying if we are performing arithmetic shift right
input left_shift_entry_wire, //signal that enters the register when doing left-shift
input clk, //clock signal
input [8:0]a, //load input bus
output [8:0]q, //output bus
output [8:0]not_q //inverted output bus
);

wire [1:0]enc;
wire [8:0]d;
wire right_shift_a7;

encoder4_2 e_inst(.i({lshift, rshift, load, 1'b0}), .o(enc)); //encodes the input signals to an enc bus that goes to the multiplexers as selection signals
mux2_1 mux2_inst(.i({q[7], q[8]}), .sel(a7_mem), .o(right_shift_a7)); //selects whether a7 will retain its value or will receive a8 when doing right shift

genvar i;
generate
	for(i=0;i<=8;i=i+1)
		begin: d_flip_flop
			d_flip_flop d_inst(.d(d[i]), .clk(clk), .q(q[i]), .not_q(not_q[i])); //flip-flops of the register
		end
endgenerate

genvar j; //used 4:2 multiplexers for selecting the input signal for each flip-flop, each of them selects signals in the following order: 
//q[i-1] (when doing left-shift), q[i+1] output (when doing right-shift), load input, current state (memory) (if no input signal is set to 1 we will memorize the current state)
generate
	for(i=0;i<=8;i=i+1)
		begin: mux4_1
			if(i==0)
			mux4_1 mux4_inst0(.i({left_shift_entry_wire, q[i+1], a[i], q[i]}), .sel(enc), .o(d[i])); //least significant bit
			else 
			if (i==7)
			mux4_1 mux4_inst1(.i({q[i-1], right_shift_a7, a[i], q[i]}), .sel(enc), .o(d[i])); //a[7]
			else if (i==8)
			mux4_1 mux4_inst2(.i({q[i-1], 1'b0, a[i], q[i]}), .sel(enc), .o(d[i])); //most significant bit
			else
			mux4_1 mux4_inst3(.i({q[i-1], q[i+1], a[i], q[i]}), .sel(enc), .o(d[i]));
		end
endgenerate

endmodule

module register_A_tb();

reg load;
reg rshift;
reg lshift;
reg a7_mem;
reg left_shift_entry_wire;
reg clk;
reg [8:0]a; //semnalele care intra in registru la load
wire [8:0]q;
wire [8:0]not_q;

register_A DUT_REGA(.load(load), .rshift(rshift), .lshift(lshift), .a7_mem(a7_mem), .left_shift_entry_wire(left_shift_entry_wire), .clk(clk), .a(a), .q(q), .not_q(not_q));

initial begin
clk=1'b0;
repeat (70) #(50) clk=~clk;
end

initial begin
a=8'b00010111;
load=1;
lshift=0;
rshift=0;
left_shift_entry_wire=0;
a7_mem=0;
#100;
a=8'b01101010;
#100;
load=0;
rshift=1;
#100;
rshift=0;
lshift=1;
#200;
lshift=0;
rshift=1;
a7_mem=1;
#300;
a7_mem=0;
rshift=0;
load=1;
a=9'b111010101;
#100;
load=0;
rshift=1;
#300;
a7_mem=1;
#200;
a7_mem=0;
rshift=0;
end

endmodule
