`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:26 04/04/2016 
// Design Name: 
// Module Name:    mux_2_1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux_2_1(out, select, in1, in2);
parameter width = 5;
	
	output [width-1:0] out;
	input select;
	input [width-1:0] in1;
	input [width-1:0] in2;
	
	//N bit wide 2 to 1 Mux
	assign out = select ? in2:in1;

endmodule
