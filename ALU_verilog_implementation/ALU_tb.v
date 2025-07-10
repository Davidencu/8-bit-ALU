`include"data_path.v"
`include"control_unit.v"

module ALU_tb(); //ALU testbench, we connect the data path and control unit inside the testbench to form a fully functional 8-bit ALU

reg clk;
reg rst;
reg bgn;
wire endd;
wire load_A;
wire load_Q;
wire load_M;
wire load_QP;
wire load_cnt;
wire a7_mem;
wire [8:0]rega;
wire [8:0]regq;
wire lshift_A;
wire rshift_A;
wire lshift_Q;
wire rshift_Q;
wire lshift_M;
wire lshift_QP;
wire c_up_QP;
wire c_up_cnt1;
wire c_up_cnt2;
wire c_down_cnt1;
wire exor_in;
wire sel_bus_mux1;
wire sel_bus_mux2;
wire sel_bus_mux6;
wire [8:0]sum;
//wire sel_AM_or_QQP;
wire sel_bus_mux3;
wire sel_bus_mux5;
wire sel_bus_mux7;
wire sel_bus_demux_1;
wire sel_bus_demux_2;
wire sel_bus_demux_3;
reg [7:0]operand1;
reg [7:0]operand2;
wire booth_digit_for_Q;
wire booth_digit_for_QP;
wire [15:0]outbus;
wire cnt7;
wire cnt0;
wire [2:0]cnt1_out;
wire [2:0]cnt2_out;
wire [2:0]not_cnt1_out;
wire [2:0]not_cnt2_out;
wire cout;
wire [7:0]regM;
wire [7:0]regQP;
wire [8:0]not_regA;
wire [8:0]not_regQ;
wire [7:0]not_regM;
wire [7:0]not_regQP;
wire [2:0]booth_digits;
wire m7;
wire a8;
reg [1:0]op;


data_path DUT_DATA_PATH(
.clk(~clk),
.load_reg_A(load_A),
.load_reg_Q(load_Q),
.load_reg_M(load_M),
.load_reg_QP(load_QP),
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
.sel_bus_mux6(sel_bus_mux6),
.sel_bus_mux7(sel_bus_mux7),
.sel_bus_mux3(sel_bus_mux3),
.sel_mux_4(lshift_M),
.sum(sum),
.sel_bus_mux5(sel_bus_mux5),
//.sel_AM_or_QQP(sel_AM_or_QQP),
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
.booth_digits(booth_digits),
.m7(m7),
.a8(a8)
);

control_unit DUT_CONTROL_UNIT
(
.op(op),
.rst(rst),
.clk(clk),
.bgn(bgn),
.b1(booth_digits[2]),
.b0(booth_digits[1]),
.bminus1(booth_digits[0]),
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
.sel_mux_1(sel_bus_mux1),
.sel_mux_2(sel_bus_mux2),
.sel_mux_6(sel_bus_mux6),
.sel_mux_7(sel_bus_mux7),
.sel_demux_1(sel_bus_demux_1),
.sel_demux_2(sel_bus_demux_2),
.sel_demux_3(sel_bus_demux_3),
//.sel_AM_or_QQP(sel_AM_or_QQP),
.sel_mux_3(sel_bus_mux3),
.sel_mux_5(sel_bus_mux5),
.rshift_A(rshift_A),
.rshift_Q(rshift_Q),
.lshift_A(lshift_A),
.lshift_Q(lshift_Q),
.lshift_M(lshift_M),
.lshift_QP(lshift_QP),
.c_up_1(c_up_cnt1),
.c_up_2(c_up_cnt2),
.c_down_1(c_down_cnt1),
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
operand1=144; //type first operand here, in decimal (for division it has to be 8 bit positive)
operand2=5; //type second operand here, in decimal (for division it has to be 8 bit positive)
op=11; //00 for addition, 01 for subtraction, 10 for multiplication, 11 for division
bgn=0;
rst=1;
#100;
rst=0;
bgn=1;
#100;
bgn=0;
end

endmodule