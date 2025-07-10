`include "parallel_adder.v"
`include "full_adder_cell.v"
`include "register_A.v"
`include "register_Q.v"
`include "register_M.v"
`include "register_QP.v"
`include "exor_wordgate.v"
`include "counter_3_bit.v"
`include "bus_mux.v"
`include "bus_demux.v"
`include "booth_encoder.v"

module data_path(
input clk, //clock signal
input load_reg_A, //control unit output, loads register A
input load_reg_Q, //control unit output, loads register Q
input load_reg_M, //control unit output, loads register M
input load_reg_QP, //control unit output, loads register QP
input load_cnt, //control unit output, loads the two counters
input a7_mem, //control unit output, used for arithmetic shift right register A
input lshift_A, //control unit output, left shift register A
input rshift_A, //control unit output, right shift register A
input lshift_Q, //control unit output, left shift register Q
input rshift_Q, //control unit output, right shift register Q
input lshift_M, //control unit output, left shift register M
input lshift_QP, //control unit output, right shift register M
input c_up_QP, //control unit output, used to increment register QP (add 1)
input c_up_cnt1, //control unit output, increments counter 1
input c_up_cnt2, //control unit output, increments counter 2
input c_down_cnt1, //control unit output, decrements counter 1
input exor_in, //control unit output, used for substraction
input sel_bus_mux1, //control unit output, selection signal for mux 1
input sel_bus_mux2, //control unit output, selection signal for mux 2
input sel_bus_mux3, //control unit output, selection signal for mux 3
input sel_mux_4, //control unit output, selection signal for mux 4
input sel_bus_mux5, //control unit output, selection signal for mux 5
input sel_bus_mux6, //control unit output, selection signal for mux 6
input sel_bus_mux7, //control unit output, selection signal for mux 7
input sel_bus_demux_1, //control unit output, selection signal for demux 1
input sel_bus_demux_2, //control unit output, selection signal for demux 2
input sel_bus_demux_3, //control unit output, selection signal for demux 3
input [7:0]operand1, //ALU input
input [7:0]operand2, //ALU input
input booth_digit_for_Q, //control unit output, used for division when doing left shift
input booth_digit_for_QP, //control unit output, used for division when doing left shift
output [15:0]outbus, //ALU output
output cnt7, //control unit input, specifies if counter 2 is set to 7
output cnt0, //control unit input, specifies if counter 1 is set to 0
output [2:0]cnt1_out, //counter 1 output
output [2:0]cnt2_out, //counter 2 output
output [2:0] not_cnt1_out, //inverted counter 1 output
output [2:0] not_cnt2_out, //inverted counter 2 output
output cout, //parallel adder carry out
output [8:0]rega, //register A output
output [8:0]sum, //parallel adder output
output [8:0]regq, //register Q output
output [7:0]regM, //register M output
output [7:0]regQP, //register QP output
output [8:0]not_regA, 
output [8:0]not_regQ,
output [7:0]not_regQP,
output [7:0]not_regM,
output [2:0]booth_digits, 
			//booth_digits[2]=1 => booth encoding represents a 1
			  //booth_digits[1]=1 => booth encoding represents a 0
			  //booth_digits[0]=1 => booth encoding represents a -1
output m7, //m[7]
output a8 //a[8]
);

wire [8:0]d3_to_m2;
wire [8:0]d3_to_m1;
wire [8:0]regA_to_d2;
wire [8:0]d2_to_m5;
wire [7:0]qp_to_m3;
wire [8:0]m3_to_ex;
wire [7:0]regM_to_m3;
wire [8:0]m5_to_pa;
wire [8:0]ex_to_pa;
wire [8:0]pa_to_d3;
wire m4_to_regQ;
wire [8:0]regQ_to_d1;
wire [7:0]m2_to_regQ;
wire [8:0]m1_to_regA;
wire [7:0]d1_to_m5;
wire [8:0]outbus0; 
wire [2:0]booth_unconverted_digits; //a group of 3 digits that will enter the booth encoder

//instantiation of the registers, counters and multiplexers

register_A regA(.load(load_reg_A), .rshift(rshift_A), .lshift(lshift_A), .a7_mem(a7_mem), .left_shift_entry_wire(regQ_to_d1[8]), .clk(clk), .a(m1_to_regA), .q(regA_to_d2), .not_q(not_regA));
register_Q regQ(.load(load_reg_Q), .rshift(rshift_Q), .lshift(lshift_Q), .clk(clk), .right_shift_entry_wire(regA_to_d2[0]), .qq({m2_to_regQ, 1'b0}), .left_shift_entry_wire(m4_to_regQ), .q(regQ_to_d1), .not_q(not_regQ));
register_M M(.load(load_reg_M), .m(operand2), .lshift(lshift_M), .left_shift_entry_wire(1'b0), .clk(clk), .q(regM_to_m3), .not_q(not_regM));
register_QP QP(.load(load_reg_QP), .m(8'b0), .lshift(lshift_QP), .c_up(c_up_QP), .left_shift_entry_wire(booth_digit_for_QP), .clk(clk), .q(qp_to_m3), .not_q(not_regQP));
counter_3_bit CNT1(.c_up(c_up_cnt1), .c_down(c_down_cnt1), .load(load_cnt), .clk(clk), .initial_value(3'b0), .q(cnt1_out), .not_q(not_cnt1_out));
counter_3_bit CNT2(.c_up(c_up_cnt2), .c_down(1'b0), .load(load_cnt), .clk(clk), .initial_value(3'b0), .q(cnt2_out), .not_q(not_cnt2_out));
parallel_adder PA(.x(m5_to_pa), .y(ex_to_pa), .cin(exor_in), .sum(pa_to_d3), .cout(cout));
bus_mux #(.w(8)) mux2(.i1(d3_to_m2[7:0]), .i2(operand1[7:0]), .sel(sel_bus_mux2), .o(m2_to_regQ));
bus_mux #(.w(9)) mux1(.i1(d3_to_m1[8:0]), .i2(9'b0), .sel(sel_bus_mux1), .o(m1_to_regA));
bus_mux #(.w(9)) mux3(.i1({1'b0, qp_to_m3}), .i2({1'b0, regM_to_m3}), .sel(sel_bus_mux3), .o(m3_to_ex));
mux2_1 mux4(.i({regM[7], booth_digit_for_Q}), .sel(lshift_M), .o(m4_to_regQ));
bus_mux #(.w(9)) mux5(.i1({1'b0,d1_to_m5}), .i2(d2_to_m5), .sel(sel_bus_mux5), .o(m5_to_pa));
bus_demux #(.w(8))demux1(.i(regQ_to_d1[8:1]), .sel(sel_bus_demux_1), .o1(d1_to_m5), .o2(outbus[7:0]));
bus_demux #(.w(9))demux2(.i(regA_to_d2), .sel(sel_bus_demux_2), .o1(outbus0), .o2(d2_to_m5));
bus_demux #(.w(9))demux3(.i(pa_to_d3), .sel(sel_bus_demux_3), .o1(d3_to_m2), .o2(d3_to_m1));
exor_wordgate EX(.word(m3_to_ex), .control_signal(exor_in), .o(ex_to_pa));
bus_mux #(.w(3)) mux6(.i1(regA_to_d2[8:6]), .i2({regQ_to_d1[1], regQ_to_d1[0], regQ_to_d1[0]}), .sel(sel_bus_mux6), .o(booth_unconverted_digits)); 
booth_encoder BE(.i(booth_unconverted_digits), .o(booth_digits));
bus_mux #(.w(9)) mux7(.i1({9{regQ_to_d1[8]}}), .i2(outbus0), .sel(sel_bus_mux7), .o(outbus[15:8]));

//booth encoder encodes a group of 3 digits according to the following table
// 000 represents a booth 0 => booth_digits[1]=1
// 001 represents a booth 1 => booth_digits[2]=1
// 010 represents a booth 1 => booth_digits[2]=1
// 011 represents a booth 1 => booth_digits[2]=1
// 100 represents a booth -1 => booth_digits[0]=1
// 101 represents a booth -1 => booth_digits[0]=1
// 110 represents a booth -1 => booth_digits[0]=1
// 111 represents a booth 0 => booth_digits[1]=1

assign cnt7=cnt2_out[2]&cnt2_out[1]&cnt2_out[0];
assign cnt0=~(cnt1_out[2]|cnt1_out[1]|cnt1_out[0]);
assign rega=regA_to_d2;
assign regq=regQ_to_d1;
assign regM=regM_to_m3;
assign sum=pa_to_d3;
assign regQP=qp_to_m3;
assign m7=regM_to_m3[7];
assign a8=regA_to_d2[8];
endmodule

module data_path_tb();

reg clk;
reg load_reg_A;
reg load_reg_Q;
reg load_reg_M;
reg load_reg_QP;
reg load_cnt;
reg a7_mem;
reg lshift_A;
reg rshift_A;
reg lshift_Q;
reg rshift_Q;
reg lshift_M;
reg lshift_QP;
reg c_up_QP;
reg c_up_cnt1;
reg c_up_cnt2;
reg c_down_cnt1;
reg exor_in;
reg sel_bus_mux1;
reg sel_bus_mux2;
reg sel_bus_mux3;
reg sel_mux_4;
reg sel_bus_mux5;
reg sel_bus_mux6;
reg sel_bus_mux7;
//reg sel_AM_or_QQP;
reg sel_bus_demux_1;
reg sel_bus_demux_2;
reg sel_bus_demux_3;
reg [7:0]operand1;
reg [7:0]operand2;
reg booth_digit_for_Q;
reg booth_digit_for_QP;
wire [8:0]rega;
wire [8:0]regq;
wire [15:0]outbus;
wire cnt7;
wire cnt0;
wire [8:0]sum;
wire [2:0]cnt1_out;
wire [2:0]cnt2_out;
wire [2:0] not_cnt1_out;
wire [2:0] not_cnt2_out;
wire cout;
wire [7:0]regM;
wire [7:0]regQP;
wire [8:0]not_regA;
wire [8:0]not_regQ;
wire [7:0]not_regQP;
wire [7:0]not_regM;
wire [2:0]booth_digits;

data_path DUT_DATA_PATH(
.clk(clk),
.load_reg_A(load_reg_A),
.load_reg_Q(load_reg_Q),
.load_reg_M(load_reg_M),
.load_reg_QP(load_reg_QP),
.load_cnt(load_cnt),
.a7_mem(a7_mem),
.rega(rega),
.regq(regq),
.lshift_A(lshift_A),
.rshift_A(rshift_A),
.lshift_Q(lshift_Q),
.rshift_Q(rshift_Q),
.lshift_M(lshift_M),
.lshift_QP(lshift_QP),
.c_up_QP(c_up_QP),
.c_up_cnt1(c_up_cnt1),
.c_up_cnt2(c_up_cnt2),
.c_down_cnt1(c_down_cnt1),
.exor_in(exor_in),
.sel_bus_mux1(sel_bus_mux1),
.sel_bus_mux2(sel_bus_mux2),
.sel_bus_mux3(sel_bus_mux3),
.sel_mux_4(sel_mux_4),
.sum(sum),
.sel_bus_mux5(sel_bus_mux5),
.sel_bus_mux6(sel_bus_mux6),
.sel_bus_mux7(sel_bus_mux7),
.sel_bus_demux_1(sel_bus_demux_1),
.sel_bus_demux_2(sel_bus_demux_2),
.sel_bus_demux_3(sel_bus_demux_3),
.operand1(operand1),
.operand2(operand2),
.booth_digit_for_Q(booth_digit_for_Q),
.booth_digit_for_QP(booth_digit_for_QP),
.outbus(outbus),
.cnt7(cnt7),
.cnt0(cnt0),
.cnt1_out(cnt1_out),
.cnt2_out(cnt2_out),
.not_cnt1_out(not_cnt1_out),
.not_cnt2_out(not_cnt2_out),
.cout(cout),
.regM(regM),
.regQP(regQP),
.not_regA(not_regA),
.not_regQ(not_regQ),
.not_regQP(not_regQP),
.not_regM(not_regM),
.booth_digits(booth_digits)
);

localparam CLK_PERIOD = 100;
localparam RUNNING_CYCLES = 80;

initial begin
clk = 1'd0;
repeat (2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
operand1=8'b10010000;
operand2=8'b00000101;
exor_in=0;
load_reg_Q=1;
load_reg_QP=1;
load_cnt=1;
load_reg_A=1;
load_reg_M=0;
c_up_cnt1=0;
c_up_cnt2=0;
sel_bus_mux1=0;
sel_bus_mux2=0;
sel_bus_mux3=0; 
sel_mux_4=0;
sel_bus_mux5=0;
sel_bus_mux6=1;
sel_bus_mux7=0;
//sel_AM_or_QQP=0;
sel_bus_demux_1=0;
sel_bus_demux_2=0;
sel_bus_demux_3=0;
lshift_A=0;
rshift_A=0;
lshift_Q=0;
rshift_Q=0;
lshift_M=0;
booth_digit_for_Q=0;
booth_digit_for_QP=0;
lshift_QP=0;
c_up_QP=0;
c_down_cnt1=0;
a7_mem=0;
#100;
load_reg_Q=0;
load_reg_QP=0;
load_cnt=0;
load_reg_A=0;
load_reg_M=1;
#100;
load_reg_M=0;
lshift_A=1;
lshift_Q=1;
lshift_M=1;
sel_mux_4=1;
c_up_cnt1=1;
#500;
lshift_A=0;
lshift_Q=0;
lshift_M=0;
sel_mux_4=0;
c_up_cnt1=0;
lshift_A=1;
lshift_Q=1;
lshift_QP=1;
#100;
c_up_cnt2=1;
#100;
booth_digit_for_Q=1;
#100;
c_up_cnt2=0;
lshift_A=0;
lshift_Q=0;
lshift_QP=0;
load_reg_A=1;
exor_in=1;
sel_bus_mux1=1;
#100;
c_up_cnt2=1;
load_reg_A=0;
exor_in=0;
lshift_A=1;
lshift_Q=1;
lshift_QP=1;
booth_digit_for_Q=0;
#300;
booth_digit_for_QP=1;
#100;
c_up_cnt2=0;
booth_digit_for_QP=0;
lshift_A=0;
lshift_Q=0;
lshift_QP=0;
load_reg_A=1;
#100;
load_reg_A=0;
lshift_A=1;
lshift_Q=1;
lshift_QP=1;
booth_digit_for_QP=1;
c_up_cnt2=1;
#100;
c_up_cnt2=0; //cnt7=1
lshift_A=0;
lshift_Q=0;
lshift_QP=0;
load_reg_A=1;
c_up_QP=1;
#100;
c_up_QP=0; //adding M to A for correction

#100;
load_reg_A=0;
load_reg_Q=1;
sel_bus_demux_3=1;
sel_bus_demux_1=1;
exor_in=1;
sel_bus_mux5=1; 
sel_bus_mux3=1; 
sel_bus_mux2=1;

#100;
load_reg_Q=0;
sel_bus_demux_3=0;
rshift_A=1;
exor_in=0;
c_down_cnt1=1;
sel_bus_demux_2=1;
sel_bus_demux_1=0;
sel_bus_mux5=0;
sel_bus_mux3=0;

#500

rshift_A=0;
c_down_cnt1=0;

end

endmodule