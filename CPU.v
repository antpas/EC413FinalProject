`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:10 04/04/2016 
// Design Name: 
// Module Name:    CPU 
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
module CPU( 
	input clk,
	input rst,
	output [31:0] PC_OUT
	);
	
	reg [31:0] PC;
	reg [31:0] IR;
	
	//Initialize PC and IR registers
	initial
	begin
		PC <= 32'b0;
		IR <= 32'b0;
	end
	
	//Wire for PC Register
	assign PC_OUT = PC;
	
	//Control Wires
	wire PCWrite;
	wire PCWriteCond;
	wire MemRead;
	wire MemWrite;
	wire MemtoReg;
	wire InstrRegWrite;
	wire [1:0] PCSource;
	wire [2:0] ALUOp;
	wire [1:0] ALUSrcB;
	wire [1:0] ALUSrcA;
	wire RegRead1;
	wire RegRead2;
	wire RegWrite;
	wire ImmExtend;
	wire BranchType;
	wire [1:0] RegWordPos;
	
	wire [31:0] IR_in;
	
	//Instruction memory
	IMem im(
		.PC(PC[15:0]),
		.Instruction(IR_in)
	);
	
	//Control state machine
	FSM stateMachine (
		.opcode(IR[31:26]), 
		.clk(clk), 
		.rst(rst), 
		.PCWrite(PCWrite), 
		.PCWriteCond(PCWriteCond), 
		.MemRead(MemRead), 
		.MemWrite(MemWrite), 
		.MemtoReg(MemtoReg), 
		.InstrRegWrite(InstrRegWrite), 
		.PCSource(PCSource), 
		.ALUop(ALUOp), 
		.ALUSrcB(ALUSrcB), 
		.ALUSrcA(ALUSrcA), 
		.RegRead1(RegRead1), 
		.RegRead2(RegRead2), 
		.RegWrite(RegWrite), 
		.ImmExtend(ImmExtend), 
		.BranchType(BranchType),
		.RegWordPos(RegWordPos)
	);
	
	//wires for register file
	wire [31:0] regFileWriteData;
	wire [31:0] readData1;
	wire [31:0] readData2;
	wire [4:0] readSe1;
	wire [4:0] readSe2;
	
	//Mux to for Read Select 1 to regfile
	mux_2_1 #(.width(5)) regFileSelect1 (
		.out(readSe1),
		.select(RegRead1),
		.in1(IR[25:21]),
		.in2(IR[20:16])
	);
	
	//Mux to for Read Select 2 to regfile
	mux_2_1 #(.width(5)) regFileSelect2 (
		.out(readSe2),
		.select(RegRead2),
		.in1(IR[25:21]),
		.in2(IR[15:11])
	);
	
	//Register File
	nbit_register_file regFile (
		.write_data(regFileWriteData),
		.read_data_1(readData1),
		.read_data_2(readData2),
		.read_sel_1(readSe1),
		.read_sel_2(readSe2),
		.write_address(IR[25:21]),
		.RegWrite(RegWrite),
		.WordPosition(RegWordPos),
		.clk(clk)
	);
	
	//Registers that hold Reg File data
	reg [31:0] A;
	reg [31:0] B;
	
	//wires for selecting SE or ZE
	wire [31:0] immExtIn1;
	wire [31:0] immExtIn2;
	wire [31:0] immExtendOut;
	
	//Sign Extended Immediate
	assign immExtIn1 = {{16{IR[15]}}, IR[15:0]};
	
	//Zero Extended immediate
	assign immExtIn2 = {16'b0, IR[15:0]};
	
	//MUX to select between SE and ZE
	mux_2_1 #(.width(32)) immExtender(
		.out(immExtendOut),
		.select(ImmExtend),
		.in1(immExtIn1),
		.in2(immExtIn2)
	);
	
	//ALU input wires
	wire [31:0] ALUSrc1;
	wire [31:0] ALUSrc2;
	
	//MUX to select first input of ALU
	mux_3_1 #(.width(32)) aluIn1 (
		.out(ALUSrc1),
		.select(ALUSrcA),
		.in1(PC),
		.in2(32'b0),
		.in3(A)
	);
	
	//MUX to select second input of ALU
	mux_3_1 #(.width(32)) aluIn2 (
		.out(ALUSrc2),
		.select(ALUSrcB),
		.in1(B),
		.in2(32'b1),
		.in3(immExtendOut)
	);
	
	//ALU Output wires
	wire [31:0] ALUOutWire;
	wire ALUZero;
	
	//ALU
	Ideal_ALU alu (
		.R1(ALUOutWire),
		.Zero(ALUZero),
		.R2(ALUSrc1),
		.R3(ALUSrc2),
		.ALUOp(ALUOp)
	);
	
	//Register to hold ALuout(branch target computation)
	reg [31:0] ALUOut;
	
	//Holds the ALUOUT != 0
	wire ALUZeroInv;
	not branchInv(ALUZeroInv, ALUZero);
	
	//Wire that holds whether or not to branch based on BEQ/BNE
	wire branchCon;
	
	//Selects between Zero(BEQ) and !Zero(BNE)
	mux_2_1 #(.width(1)) branchMux(
		.out(branchCon),
		.select(BranchType),
		.in1(ALUZero),
		.in2(ALUZeroInv)
	);
	
	wire branchCond;
	wire PCEnable;
	
	//Logic on whether to write to PC
	//Conditionally write on branch, always on PCwrite
	and (branchCond, PCWriteCond, branchCon);
	or (PCEnable, branchCond, PCWrite);
	
	wire [31:0] PCData;
	
	//Mux to select PC source
	//PC + 4, Branch Target, Jump Target
	mux_3_1 #(.width(32)) pcSrc (
		.out(PCData),
		.select(PCSource),
		.in1(ALUOutWire),
		.in2(ALUOut),
		.in3({PC[31:26], IR[25:0]})
	);

	wire [31:0] dataMemOut;
	
	//Data memory
	DMem dataMem (
		.WriteData(B),
		.MemData(dataMemOut),
		.Address(ALUOut[15:0]),
		.MemWrite(MemWrite),
		.Clk(clk)
	);
	
	//Holds output of data memory
	reg [31:0] memDataRegister;
	
	//Selects between writing with ALUOut or value from memory
	mux_2_1 #(.width(32)) regWriteDataMux(
		.out(regFileWriteData),
		.select(MemtoReg),
		.in1(ALUOut),
		.in2(memDataRegister)
	);
	
	//Write to PC if it is enabled
	always@(negedge clk)
	begin
		if(PCEnable == 1'b1)
		begin
			PC <= PCData;
		end
	end
	
	//Update Registers
	always@(negedge clk)
	begin
		A <= readData1;
		B <= readData2;
		ALUOut <= ALUOutWire;
		memDataRegister <= dataMemOut;
		if(InstrRegWrite)
			IR <= IR_in;
	end
	
endmodule

