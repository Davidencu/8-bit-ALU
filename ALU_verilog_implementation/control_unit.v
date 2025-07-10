`include"d_flip_flop.v"
`include"mux2_1.v"

module control_unit( //uses one hot encoding, based on a moore fsm (outputs rely on the current state)
input [1:0]op, //operation encoding, ALU input (00 = addition, 01 = subtraction, 10 = multiplication, 11 = division
input rst, //brings the control unit to the initial state (q[0] is 1)
input clk, //clock signal
input bgn, //orders the control unit to start executing the instructions
input a8, //a[8]
input b1, //if booth encoding represents positive 1
input b0, //if booth encoding represents 0
input bminus1, //if booth encoding represents negative 1 
input m7, //if M[7] equals 0, signal used for division
input cnt0, //signal used only for division, if it's equal to 1, it means that the quotient is A
input cnt7, //sigmal used for multiplication and division
output endd, //it is 1 if there are no more instructions to execute and the algorithm ends
output load_A,
output load_Q,
output load_M,
output load_QP,
output load_cnt,
output sel_mux_1,
output sel_mux_2,
output sel_mux_6,
output sel_mux_7,
output sel_demux_1,
output sel_demux_2,
output sel_demux_3,
output sel_mux_3,
output sel_mux_5,
output rshift_A,
output rshift_Q,
output lshift_A,
output lshift_Q,
output lshift_M,
output lshift_QP,
output booth_digit_for_Q,
output booth_digit_for_QP,
output c_up_1,
output c_up_2,
output c_up_QP,
output c_down_1,
output exor_in,
output a7_mem //arithmetic shift right for register A
//output [18:0]o //used only for testing the control unit
);

wire[15:0]d; //wire signal which enters a d flip flop
wire[15:0]q; //the set of states of the control unit
wire[15:0]not_q;

genvar i;
generate
for(i=0;i<=15;i=i+1)
begin: d_flip_flop
	d_flip_flop DUT_FF(.clk(clk), .d(d[i]), .q(q[i]), .not_q(not_q[i]));
end
endgenerate

//assigning the next state values depending on the current state, the multiplexers are used to decide whether the next state will be 0 (rst signal is 1) or other state (rst signal is 0)
//implemented using d flip-flops and multiplexers that specify if we should bring the fsm to the initial state (rst=1) or not
//the states are represented by the outputs of the flip-flops which are q[15:0]

mux2_1 DUT_MUX0(.i({1'b1, 
q[0]&~(bgn) //q[0]=q[0]&~(bgn)
}), .sel(rst), .o(d[0]));

mux2_1 DUT_MUX1(.i({1'b0, 
(q[0]|q[15])&bgn //q[1]=(q[0]|q[15])&bgn
}), .sel(rst), .o(d[1]));

mux2_1 DUT_MUX2(.i({1'b0,
q[1]&(~(op[1]|op[0])) //q[2]=q[1]&(~(op[1]|op[0]))
}), .sel(rst), .o(d[2]));

mux2_1 DUT_MUX3(.i({1'b0,
q[1]&~(op[1])&op[0] //q[3]=q[1]&~(op[1])&op[0]
}), .sel(rst), .o(d[3]));

mux2_1 DUT_MUX4(.i({1'b0,
(q[10])|(q[7]&(~op[0])&b1)|(op[1]&~op[0]&q[1]&b1) //q[4]=(q[10])|(q[7]&(~op[0])&b1)|(op[1]&~op[0]&q[1]&b1)
}), .sel(rst), .o(d[4]));

mux2_1 DUT_MUX5(.i({1'b0,
(q[1]&op[1]&(~op[0])&b0)|(q[4]&(~op[0]))|(q[6]&(~op[0]))|(q[7]&(~op[0])&b0) //q[5]=(q[1]&op[1]&(~op[0])&b0)|(q[4]&(~op[0]))|(q[6]&(~op[0]))|(q[7]&(~op[0])&b0)
}), .sel(rst), .o(d[5]));

mux2_1 DUT_MUX6(.i({1'b0,
(q[1]&op[1]&(~op[0])&bminus1)|(q[11])|(q[7]&(~op[0])&bminus1) //q[6]=(q[1]&op[1]&(~op[0])&bminus1)|(q[11])|(q[7]&(~op[0])&bminus1)
}), .sel(rst), .o(d[6]));

mux2_1 DUT_MUX7(.i({1'b0,
(q[5]&(~cnt7))|(q[4]&op[0]&(~cnt7))|(q[6]&op[0]&(~cnt7))|(q[9]&(~cnt7)) //q[7]=(q[5]&(~cnt7))|(q[4]&op[0]&(~cnt7))|(q[6]&op[0]&(~cnt7))|(q[9]&(~cnt7))
}), .sel(rst), .o(d[7]));

mux2_1 DUT_MUX8(.i({1'b0,
(q[1]&op[1]&op[0]&(~m7))|(q[8]&(~m7)) //q[8]=(q[1]&op[1]&op[0]&(~m7))|(q[8]&(~m7))
}), .sel(rst), .o(d[8]));

mux2_1 DUT_MUX9(.i({1'b0,
(q[8]&b0&m7)|(q[1]&op[1]&op[0]&m7&b0)|(q[7]&op[0]&b0) //q[9]=(q[8]&b0&m7)|(q[1]&op[1]&op[0]&m7&b0)|(q[7]&op[0]&b0)
}), .sel(rst), .o(d[9]));

mux2_1 DUT_MUX10(.i({1'b0,
(q[8]&bminus1&m7)|(q[1]&op[1]&op[0]&m7&bminus1)|(q[7]&op[0]&bminus1) //q[10]=(q[8]&bminus1&m7)|(q[1]&op[1]&op[0]&m7&bminus1)|(q[7]&op[0]&bminus1)
}), .sel(rst), .o(d[10]));

mux2_1 DUT_MUX11(.i({1'b0,
(q[8]&b1&m7)|(q[1]&op[1]&op[0]&m7&b1)|(q[7]&op[0]&b1) //q[11]=(q[8]&b1&m7)|(q[1]&op[1]&op[0]&m7&b1)|(q[7]&op[0]&b1)
}), .sel(rst), .o(d[11]));

mux2_1 DUT_MUX12(.i({1'b0,
((q[4]|q[6]|q[9])&op[0]&cnt7&a8&(~cnt0)) //q[12]=((q[4]|q[6]|q[9])&op[0]&cnt7&a8&(~cnt0))
}), .sel(rst), .o(d[12]));

mux2_1 DUT_MUX13(.i({1'b0,
((q[4]|q[6]|q[9])&op[0]&cnt7&(~a8)&(~cnt0))|(q[12])|(q[13]&(~cnt0)) //q[13]=((q[4]|q[6]|q[9])&op[0]&cnt7&(~a8)&(~cnt0))|(q[12])|(q[13]&(~cnt0))
}), .sel(rst), .o(d[13]));

mux2_1 DUT_MUX14(.i({1'b0,
(q[13]&cnt0)|((q[4]|q[6]|q[9])&op[0]&cnt7&(~a8)&cnt0) //q[14]=(q[13]&cnt0)|((q[4]|q[6]|q[9])&op[0]&cnt7&(~a8)&cnt0)
}), .sel(rst), .o(d[14]));

mux2_1 DUT_MUX15(.i({1'b0,
(q[14])|(q[2])|(q[3])|(q[5]&cnt7)|(q[15]&(~bgn)) //q[15]=(q[14])|(q[2])|(q[3])|(q[5]&cnt7)|(q[15]&(~bgn))
}), .sel(rst), .o(d[15]));

//assigning outputs depending on the current state

assign load_A=q[1]|q[4]|q[6]|q[12];
assign load_Q=q[1]|q[2]|q[3]|q[14];
assign load_M=q[1];
assign load_QP=q[1];
assign load_cnt=q[1];
assign rshift_A=q[5]|q[13];
assign rshift_Q=q[5];
assign lshift_A=q[8]|q[9]|q[10]|q[11];
assign lshift_Q=q[8]|q[9]|q[10]|q[11];
assign lshift_M=q[8];
assign lshift_QP=q[9]|q[10]|q[11];
assign c_up_1=q[8];
assign c_up_2=q[7];
assign sel_mux_1=q[4]|q[6]|q[12];
assign sel_mux_2=q[2]|q[3]|q[14];
assign sel_demux_1=q[14]|q[2]|q[3];
assign sel_demux_2=q[15];
assign sel_demux_3=q[14]|q[2]|q[3];
assign sel_AM_or_QQP=q[14];
assign sel_mux_3=q[14];
assign sel_mux_5=q[14]|q[2]|q[3];	
assign sel_mux_7=~op[1];
assign booth_digit_for_Q=q[11];
assign booth_digit_for_QP=q[10];
assign c_down_1=q[13];
assign exor_in=q[3]|q[6]|q[14];
assign sel_mux_6=op[0];
assign a7_mem=op[1]&(~op[0]);
assign endd=q[15];
assign c_up_QP=q[12];

endmodule

module control_unit_tb();

reg [1:0]op;
reg rst;
reg clk;
reg bgn;
reg a8;
reg b1; //if booth encoding represents positive 1
reg b0; //if booth encoding represents 0
reg bminus1; //if booth encoding represents negative 1 
reg m7; //if M[7] equals 0, signal used for division
reg cnt0; //signal used only for division, if it's equal to 1, it means that the quotient is A
reg cnt7; //sigmal used for multiplication and division
wire endd; //it is 1 if there are no more instructions to execute and the algorithm ends
wire load_A;
wire load_Q;
wire load_M;
wire load_QP;
wire load_cnt;
wire sel_mux_1;
wire sel_mux_2;
wire sel_mux_3;
wire sel_mux_5;
wire sel_mux_6;
wire sel_mux_7;
wire sel_demux_1;
wire sel_demux_2;
wire sel_demux_3;
wire rshift_A;
wire rshift_Q;
wire lshift_A;
wire lshift_Q;
wire lshift_M;
wire lshift_QP;
wire c_up_1;
wire c_up_2;
wire c_up_QP;
wire c_down_1;
wire exor_in;
wire a7_mem; //arithmetic shift right for register A
wire booth_digit_for_Q;
wire booth_digit_for_QP;
//wire [18:0]o;

control_unit DUT_CU
(
.op(op),
.rst(rst),
.clk(clk),
.bgn(bgn),
.b1(b1),
.b0(b0),
.bminus1(bminus1),
.m7(m7),
.a8(a8),
.cnt0(cnt0),
.cnt7(cnt7),
.endd(endd),
.load_A(load_A),
.load_Q(load_Q),
.load_M(load_M),
.load_QP(load_QP),
.load_cnt(load_cnt),
.sel_mux_1(sel_mux_1),
.sel_mux_2(sel_mux_2),
.sel_mux_6(sel_mux_6),
.sel_mux_7(sel_mux_7),
.sel_demux_1(sel_demux_1),
.sel_demux_2(sel_demux_2),
.sel_demux_3(sel_demux_3),
.sel_mux_3(sel_mux_3),
.sel_mux_5(sel_mux_5),
.rshift_A(rshift_A),
.rshift_Q(rshift_Q),
.lshift_A(lshift_A),
.lshift_Q(lshift_Q),
.lshift_M(lshift_M),
.lshift_QP(lshift_QP),
.c_up_1(c_up_1),
.c_up_2(c_up_2),
.c_down_1(c_down_1),
.c_up_QP(c_up_QP),
.exor_in(exor_in),
.a7_mem(a7_mem),
.booth_digit_for_Q(booth_digit_for_Q),
.booth_digit_for_QP(booth_digit_for_QP)
//.o(o)
);

localparam CLK_PERIOD = 100;
localparam RUNNING_CYCLES = 80;

initial begin
clk = 1'd0;
repeat (2*RUNNING_CYCLES) #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
op=2'b11;
rst=1;
bgn=0;
b1=0;
b0=1;
bminus1=0;
m7=0;
cnt0=1;
cnt7=0;
a8=0;
#100;
rst=0;
bgn=1;
#100;
bgn=0;
m7=0;
#100;
cnt0=0;
#400;
m7=1;
#100;
b0=0;
bminus1=1;
#200;
bminus1=0;
b1=1;
#300;
b1=0;
b0=1;
#400;
cnt7=1;
a8=1;
m7=0;
#600;
cnt0=1;
end

endmodule