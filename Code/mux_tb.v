`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:30:16 04/04/2016
// Design Name:   mux_3_1
// Module Name:   /ad/eng/users/j/o/johnidel/X_Projects/Mile2/mux_tb.v
// Project Name:  Mile2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mux_3_1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mux_tb;

	// Inputs
	reg [1:0] select;
	reg [4:0] in1;
	reg [4:0] in2;
	reg [4:0] in3;

	// Outputs
	wire [4:0] out;

	// Instantiate the Unit Under Test (UUT)
	mux_3_1 uut (
		.out(out), 
		.select(select), 
		.in1(in1), 
		.in2(in2), 
		.in3(in3)
	);

	initial begin
		// Initialize Inputs
		select = 0;
		in1 = 5'b11111;
		in2 = 5'b11000;
		in3 = 5'b1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		select = 2'b1;
		#40
		select = 2'b10;
		#40
		select = 2'b00;

	end
      
endmodule

