`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:10:48 03/28/2016
// Design Name:   CPU
// Module Name:   /ad/eng/users/j/o/johnidel/X_Projects/Mile2/CPU_tb.v
// Project Name:  Mile2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CPU_tb;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [31:0] PC_OUT;

	// Instantiate the Unit Under Test (UUT)
	CPU cpuu (
		.clk(clk), 
		.rst(rst), 
		.PC_OUT(PC_OUT)
	);
	
	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

