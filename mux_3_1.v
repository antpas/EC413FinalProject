`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:32 04/04/2016 
// Design Name: 
// Module Name:    mux_3_1 
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
module mux_3_1(out, select, in1, in2, in3);
parameter width = 5;
	
	output reg [width-1:0] out;
	input [1:0] select;
	input [width-1:0] in1;
	input [width-1:0] in2;
	input [width-1:0] in3;
	
	//N bit wide 3 to 1 mux
	always@(select or in1 or in2 or in3)
	begin
		if(select == 2'b00)
			out <= in1;
		else if(select == 2'b01)
			out <= in2;
		else if(select == 2'b10)
			out <= in3;
		else
			out <= 1'b0;
	end

endmodule
