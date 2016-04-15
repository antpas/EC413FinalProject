`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:01:40 03/28/2016 
// Design Name: 
// Module Name:    CPU_Control 
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
module FSM(
			input [5:0] opcode,
			input clk,
			input rst,
			output reg PCWrite,
			output reg PCWriteCond,
			output reg InstMemRead,
			output reg MemRead,
			output reg MemWrite,
			output reg MemtoReg,
			output reg InstrRegWrite,
			output reg [1:0] PCSource,
			output reg [2:0] ALUop,
			output reg [1:0] ALUSrcB,
			output reg [1:0] ALUSrcA,
			output reg RegRead1,
			output reg RegRead2,
			output reg RegWrite,
			output reg ImmExtend,
			output reg BranchType,
			output reg [1:0] RegWordPos
			);
			
			parameter	LW = 6'b100011, SW = 6'b101011, J = 6'b000001, BEQ = 6'b000100, R_type = 6'b010000;
			
			reg [3:0] state;
			reg [3:0] next_state;
			
			initial
			begin
			state = 4'b0;
			next_state = 4'b0;
			end
			
			always@(posedge clk)
			begin
				PCWrite = 0;
				PCWriteCond = 0;
				MemRead = 0;
				MemWrite = 0;
				MemtoReg = 0;
				InstrRegWrite = 0;
				PCSource = 2'b0;
				ALUop = 3'b0;
				ALUSrcB = 2'b0;
				ALUSrcA = 2'b0;
				RegRead1 = 0;
				RegRead2 = 0;
				RegWrite = 0;
				ImmExtend = 0;
				BranchType = 0;
				RegWordPos = 0;
			
				case(state)
					4'd0: 
					begin
						//write to IR and increment PC
						ALUSrcB = 2'b1;
						ALUSrcA = 2'b0;
						ALUop = 3'b010;
						InstrRegWrite = 1;
						PCWrite = 1;
						PCSource = 2'b00;
						state <= 4'd1;
					end

					4'd1:
					begin
						//Compute branch target
						ALUSrcB = 2'b10;
						ALUSrcA = 2'b0;
						ALUop = 3'b010;
						ImmExtend = 0;
						
						if(opcode[5:3] == 3'b010 || opcode[5:3] == 3'b110)
						begin
							RegRead1 = 1'b1;
							RegRead2 = 1'b1;
						end
						else if(opcode[5:3] == 3'b100)
						begin
							RegRead1 = 1'b1;
						end
						
						if(opcode == J) //J
							state <= 4'd2;
						else if(opcode[5:4] == 2'b10) //B
							state <= 4'd3;
						else if(opcode == 6'b111011 || opcode == 6'b111100) //memRef
							state <= 4'd6;
						else if(opcode[5:4] == 2'b01 || opcode[5:4] == 2'b11) //Arith
							state <= 4'd4;
						else
							state <= 4'd0;
					end

					4'd2:
					begin
						//Jump
						PCWrite = 1;
						PCSource = 2'b10;
						state <= 4'd0;
					end	
					4'd3:
					begin
						//Compute whether or not branch
						ALUSrcB = 2'b0;
						ALUSrcA = 2'b10;
						ALUop = 3'b011;
						PCWriteCond = 1;
						PCSource = 2'b1;
						//Choose Zero or !Zero as branch conditional based on BEQ and BNE
						BranchType = opcode[0];
						state <= 4'd0;
					end
					4'd4:
					begin
						//Set ALU SrcB, based on whether it is an R or I type instruction
						ALUSrcB = {opcode[5],1'b0};
			
						if(opcode == 6'b111001 || opcode == 6'b111010)
							ALUSrcA = 2'b1;
						else
							ALUSrcA = 2'b10;
						
						//If it is a LI or LUI, ALUop is add(add imm to zero)
						if(opcode == 6'b111001 || opcode == 6'b111010)
							ALUop = 3'b010;
						else
							ALUop = opcode[2:0];
							
						//Zero extend/Sign Extend if opcode calles for it
						if(ALUop == 3'b010 || ALUop == 3'b011 || ALUop == 3'b111)
							ImmExtend = 0;
						else
							ImmExtend = 1;
							
						state <= 4'd5;
					end
					4'd5:
					begin
						RegWrite = 1;
						MemtoReg = 0;
						//Write to lower half og reg if LI
						if(opcode == 6'b111001)
							RegWordPos = 2'b1;
						else if(opcode == 6'b111010) //Write to upperhalf if LUI
							RegWordPos = 2'b10;
						else
							RegWordPos = 2'b0; //Write to whole register otherwise
						state <= 4'd0;
					end
					4'd6:
					begin
						ALUop = 3'b010;
						ALUSrcB = 2'b10;
						ImmExtend = 1;
						if(opcode == 6'b111011 || opcode == 6'b111100) //IF SWI/LWI, AlU Input 1 = 0
							ALUSrcA = 2'b1;
						else
							ALUSrcA = 2'b10; //IF SW/LW, use register data
						
						if(opcode == 6'b111100 || opcode == 6'b111110) //IF SW/SWI go to state 9
								state <= 4'd9;
						else if(opcode == 6'b111011 || opcode == 6'b111101)//If LW/LWI go to state 7
								state <= 4'd7;
					end
					4'd7:
					begin
						//Read value from mem
						MemRead = 1;
						state <= 4'd8;
					end
					4'd8:
					begin
						//Write value read from mem to regfile
						MemtoReg = 1;
						RegWrite = 1;
						state <= 4'd0;
					end
					4'd9:
					begin
						//Write register to memory
						MemWrite = 1;
						state <= 4'd0;
					end
						
				endcase
				
				if(rst)
					state <= 4'b0;
			end
				



endmodule
