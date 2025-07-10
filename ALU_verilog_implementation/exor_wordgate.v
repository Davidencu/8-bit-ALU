module exor_wordgate( //the 9-bit EXOR wordgate used for implementing subtraction (9 is the maximum number of bits that we are going to use)
input [8:0]word,
input control_signal,
output [8:0]o
);

assign o=word^{9{control_signal}};

endmodule

module exor_wordgate_tb();

reg [8:0]word;
reg control_signal;
wire [8:0]o;

exor_wordgate DUT_EXOR(.word(word), .control_signal(control_signal), .o(o));

integer i;

initial begin
word=9'b100101101;
for(i=0;i<=1;i=i+1)
begin
	control_signal=i;
	#100;
end
end

endmodule
