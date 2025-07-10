module booth_encoder(input [2:0]i, output [2:0]o); 
//converts 3 digits to 3 signals, o[2] is 1 if the combination represents a booth 1
//o[1] is 1 if the combination represents a booth 0
//o[0] is 1 if the combination represents a booth -1

assign o[0]=i[2]&(~(i[1]&i[0]));
assign o[1]=((~i[2])&(~i[1])&(~i[0]))|(i[2]&i[1]&i[0]);
assign o[2]=~i[2]&(i[1]|i[0]);

endmodule