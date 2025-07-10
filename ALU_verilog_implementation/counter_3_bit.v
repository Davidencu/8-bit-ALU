`include "mux2_1.v"
`include "d_flip_flop.v"

module counter_3_bit(
input c_up, //signal for enabling count-up
input c_down, //sighnal for enabling count-down
input load, //signal for loading the register
input clk, //clock signal
input [2:0]initial_value, //the initial value of the counter, which is 0
output [2:0]q, //the output of the counter
output [2:0]not_q
);

wire [2:0]sw;
wire [2:0]w;

mux2_1 mux2_inst10(.i({initial_value[0], (not_q[0] & (c_up ^ c_down))}), .sel(load), .o(sw[0]));
mux2_1 mux2_inst11(.i({initial_value[1], ((q[0]^q[1]) & c_up & ~(c_down)) | (~(q[0]^q[1]) & ~(c_up) & c_down)}), .sel(load), .o(sw[1]));
mux2_1 mux2_inst12(.i({initial_value[2], (c_down & ~q[2] & ~q[1] & ~q[0]) | (c_down & q[2] & q[0]) | (c_down & q[2] & q[1]) | (c_up & ~q[2] & q[1] & q[0]) | (c_up & q[2] & ~q[1]) | (c_up & q[2] & ~q[0])}), .sel(load), .o(sw[2]));
mux2_1 mux2_inst13(.i({q[0],sw[0]}), .sel(~(load | c_up | c_down)), .o(w[0]));
mux2_1 mux2_inst14(.i({q[1],sw[1]}), .sel(~(load | c_up | c_down)), .o(w[1]));
mux2_1 mux2_inst15(.i({q[2],sw[2]}), .sel(~(load | c_up | c_down)), .o(w[2]));

genvar i;
generate
for(i=0;i<=2;i=i+1)
	begin: d_flip_flop
		d_flip_flop dff(.d(w[i]), .clk(clk), .q(q[i]), .not_q(not_q[i]));
	end
endgenerate

endmodule

module counter_3_bit_tb();

reg c_up;
reg c_down;
reg load;
reg clk;
reg [2:0]initial_value;
wire [2:0]q;
wire [2:0]not_q;

counter_3_bit DUT_COUNTER(.c_up(c_up), .c_down(c_down), .load(load), .clk(clk), .initial_value(initial_value), .q(q), .not_q(not_q));

initial begin
clk=1'b0;
repeat (70) #(50) clk=~clk;
end

initial begin
initial_value=3'b000;
c_up=0;
c_down=0;
load=1;
#100;
load=0;
c_up=1;
#1000;
c_up=0;
c_down=1;
#1000;
c_down=0;
end

endmodule