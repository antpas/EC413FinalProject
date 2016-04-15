`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:13:00 03/28/2016
// Design Name:   CPU_Control
// Module Name:   /ad/eng/users/j/o/johnidel/X_Projects/Mile2/cpu_control_tb.v
// Project Name:  Mile2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU_Control
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cpu_control_tb;

	// Inputs
	reg [31:0] InstrIn;
	reg clk;
	reg rst;

	// Outputs
	wire PCWrite;
	wire PCWriteCond;
	wire InstMemRead;
	wire MemRead;
	wire MemWrite;
	wire MemtoReg;
	wire InstrRegWrite;
	wire [1:0] PCSource;
	wire [2:0] ALUop;
	wire [1:0] ALUSrcB;
	wire [1:0] ALUSrcA;
	wire RegRead1;
	wire RegRead2;
	wire RegWrite;
	wire ImmExtend;
	wire RegDst;
	wire BranchType;

	// Instantiate the Unit Under Test (UUT)
	FSM uut (
		.opcode(InstrIn[31:26]), 
		.clk(clk), 
		.rst(rst), 
		.PCWrite(PCWrite), 
		.PCWriteCond(PCWriteCond), 
		.InstMemRead(InstMemRead), 
		.MemRead(MemRead), 
		.MemWrite(MemWrite), 
		.MemtoReg(MemtoReg), 
		.InstrRegWrite(InstrRegWrite), 
		.PCSource(PCSource), 
		.ALUop(ALUop), 
		.ALUSrcB(ALUSrcB), 
		.ALUSrcA(ALUSrcA), 
		.RegRead1(RegRead1), 
		.RegRead2(RegRead2), 
		.RegWrite(RegWrite), 
		.ImmExtend(ImmExtend), 
		.RegDst(RegDst), 
		.BranchType(BranchType)
	);
	
	always #1 clk = ~clk;

	initial begin
		// Initialize Inputs
		InstrIn = 0;
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		// Start to load instructions into instruction memory, one instruction is issued per clock cycle
		
		InstrIn = 32'b000000_00000_00000_0000000000000000;		// NOOP
		
		#10
		InstrIn = 32'b110010_00001_00001_0000000000000101;		// I, addi r1 with 00000005 		=> r1 = 00000005
		
		/**
		
		#10
		InstrIn = 32'b110010_00010_00010_0000000000001010;		// I, addi r2 with 0000000A 		=> r2 = 0000000A
		
		#10
		InstrIn = 32'b110010_00011_00011_1111111111111000;		// I, addi r3 with 0000FFF8 		=> r3 = FFFFFFF8
		
		#10
		InstrIn = 32'b110011_00100_00100_0000000000000001;		// I, subi r4 with 00000001 		=> r4 = FFFFFFFF
				
		#10
		InstrIn = 32'b110100_00101_00101_1010101010101010;		// I, ori r5 with 0000AAAA  		=> r5 = 00000AAAA
				
		#10
		InstrIn = 32'b110101_00110_00110_1111111111111111;		// I, andi r6 with 0000FFFF 		=> r6 = 00000000
				
		#10
		InstrIn = 32'b010000_00111_00001_0000000000000000;		// R, mov r1 to r7					=> r7 = 00000005
				
		#10
		InstrIn = 32'b010000_01000_00010_0000000000000000;		// R, mov r2 to r8					=> r8 = 0000000A
				
		#10
		InstrIn = 32'b010000_01001_00000_0000000000000000;		// R, mov r0 to r9					=> r9 = 000000000
				 
		#10
		InstrIn = 32'b010010_01010_00111_01000_00000000000;		// R, r10 = r7 + r8					=> r10 = 0000000F
				
		#10
		InstrIn = 32'b010011_01011_00111_01000_00000000000;		// R, r11 = r7 - r8					=> r11 = FFFFFFFB
		      
		#10
		InstrIn = 32'b010100_01100_00111_01001_00000000000;		// R, r12 = r7 or r9				=> r12 = 00000005
		
		#10
		InstrIn = 32'b010101_01101_01000_00100_00000000000;		// R, r13 = r8 and r4				=> r13 = 0000000A
				
		#10
		InstrIn = 32'b100000_01100_01101_1111111111110010;		// BEQ, Jump to 0 when r12 = r13
				
		#10
		InstrIn = 32'b100000_01000_01101_0000000000000001;		// BEQ, Jump to 17 when r8 = r13
				
		#10
		InstrIn = 32'b010000_01101_00000_0000000000010000;		// R, mov r0 to r13				 	=> r13 = 00000000
				
		#10
		InstrIn = 32'b111100_01101_00000_0000000000001000;		// SWI r13 to MEM address 0x08
				
		#10
		InstrIn = 32'b111011_01110_00000_0000000000001000;		// LWI r14 from MEM address 0x08   	=> r14 = 0000000A
		
		#10
		InstrIn = 32'b100001_01101_01110_0000000000000001;		// BNE, Jump to 21 when r13 != r14
				
		#10
		InstrIn = 32'b111001_01111_00000_0000000000001000;		// LI r15 from immediate 8			=> r15 = 00000008
		
		#10
		InstrIn = 32'b100001_01100_01110_0000000000000001;		// BNE, Jump to 23 when r12 != r14
		
		#10
		InstrIn = 32'b111001_01111_00000_0000000000001011;		// LI r15 from immediate B			=> r15 = 0000000B
		
		#10
		InstrIn = 32'b010111_10000_01111_01110_00000000000;		// SLT, r16 = (r15 < r14)			=> r16 = 00000001
		
		#10
		InstrIn = 32'b110111_10001_01111_1111111111111111;		// SLTI, r17 = (r15 < -1)			=> r17 = 00000000
		
		#10
		InstrIn = 32'b110111_10010_01111_0000000000001001;		// SLTI, r18 = (r15 < 9)			=> r18 = 00000001
		
		#10
		InstrIn = 32'b000001_00000_00000_0000000000000000;		// Jump to Instr 0
		**/
	end
      
endmodule

