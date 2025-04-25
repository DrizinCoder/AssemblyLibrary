module Top_Level(

	input clk,
	input [7:0] n1,
	input [7:0] n2,
	output [7:0] result
	
);
	
	Sum adder(n1, n2, result);

endmodule
