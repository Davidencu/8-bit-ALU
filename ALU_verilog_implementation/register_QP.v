`include "half_adder_cell.v"

module register_QP( //the q-prime register used for SRT radix 2 division
input load, //load the register
input [7:0]m, //input load bus
input lshift, //left shift the register
input c_up, //count up signal for the correction step
input left_shift_entry_wire, //signal that enters the register when doing left_shift
input clk, //clock register
output [7:0]q, //output bus
output [7:0]not_q //inverted output bus
);

wire [1:0]enc;
wire [7:0]d;
wire [7:0]sum;
wire [7:0]c;

encoder4_2 e_inst(.i({lshift, c_up, load, 1'b0}), .o(enc)); //I used an encoder to convert the input signals to a 2-bit bus which enters the multiplexers and play the role of selection signals

genvar i;
generate
	for(i=0;i<=7;i=i+1)
		begin: d_flip_flop
			d_flip_flop d_inst(.d(d[i]), .clk(clk), .q(q[i]), .not_q(not_q[i])); //flip-flops of the register
		end
endgenerate

generate //multiplexers select signals in the following order: left shift, count up, load, current state (memory) (if no input signal is set to 1 we will memorize the current state)
	for(i=0;i<=7;i=i+1)
		begin: mux4_1
			if(i==0)
			mux4_1 mux4_inst7(.i({left_shift_entry_wire, sum[i], m[i], q[i]}), .sel(enc), .o(d[i]));
			else
			mux4_1 mux4_inst8(.i({q[i-1], sum[i], m[i], q[i]}), .sel(enc), .o(d[i]));
		end
endgenerate

generate
	for(i=0;i<=7;i=i+1)
		begin: half_adder_cell
			if(i==0)
			half_adder_cell hac_inst0(.i({q[i], c_up}), .sum(sum[i]), .carry(c[i])); //half adder cells were used for incrementing the register
			else
			half_adder_cell hac_inst1(.i({q[i], c[i-1]}), .sum(sum[i]), .carry(c[i]));
		end
endgenerate

endmodule

module register_QP_tb();

reg load;
reg lshift;
reg left_shift_entry_wire;
reg clk;
reg [7:0]m; //semnalele care intra in registru la load
reg c_up;
wire [7:0]q;
wire [7:0]not_q;

register_QP DUT_REGQP(.load(load), .lshift(lshift), .left_shift_entry_wire(left_shift_entry_wire), .c_up(c_up), .clk(clk), .m(m), .q(q), .not_q(not_q));

initial begin
clk=1'b0;
repeat (70) #(50) clk=~clk;
end

initial begin
m=8'b00010111;
load=1;
lshift=0;
c_up=0;
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
c_up=1;
#500
c_up=0;
end

endmodule