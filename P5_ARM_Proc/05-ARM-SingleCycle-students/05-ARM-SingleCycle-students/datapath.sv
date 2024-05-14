/*
 * This module is the Datapath Unit of the ARM single-cycle processor
 */ 
module datapath(input logic clk, reset,
					 input logic [1:0] RegSrc,
					 input logic RegWrite,
					 input logic [1:0] ImmSrc,
					 input logic ALUSrc,
					 input logic [1:0] ALUControl,
					 input logic MemtoReg,
					 input logic PCSrc,
					 output logic [3:0] ALUFlags,
					 output logic [31:0] PC,
					 input logic [31:0] Instr, //Sale de Instruction Memory
					 output logic [31:0] ALU_Post_Result, WriteData,
					 input logic [31:0] ReadData,
					 input logic shift_flag);
	// Internal signals
	logic [31:0] PCNext, PCPlus4, PCPlus8;
	logic [31:0] ExtImm, SrcA, SrcB, Result;
	logic [3:0] RA1, RA2;
	logic [31:0] outShift, ALUResult;
	// next PC logic
	mux2 #(32) pcmux(PCPlus4, Result, PCSrc, PCNext); //Mux de la izq
	flopr #(32) pcreg(clk, reset, PCNext, PC); //Registro PC
	adder #(32) pcadd1(PC, 32'b100, PCPlus4);//PC +4
	adder #(32) pcadd2(PCPlus4, 32'b100, PCPlus8);//PC +8

	// register file logic
	mux2 #(4) ra1mux(Instr[19:16], 4'b1111, RegSrc[0], RA1); //Dir Registro 1
	mux2 #(4) ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);//Dir Registro 2
	regfile rf(clk, RegWrite, RA1, RA2, Instr[15:12], Result, PCPlus8, SrcA, WriteData);
	mux2 #(32) resmux(ALU_Post_Result, ReadData, MemtoReg, Result);//Data de registro o val inmediato
	extend ext(Instr[23:0], ImmSrc, ExtImm);//Extensor

	// ALU logic
	shift_mod shifter(WriteData, Instr[11:5], outShift);
	mux2 #(32) srcbmux(outShift, ExtImm, ALUSrc, SrcB);
	
	//mux2 #(32) srcbmux(WriteData, ExtImm, ALUSrc, SrcB);
	alu #(32) alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);
	mux2 #(32) shift_mux(ALUResult, SrcB, shift_flag, ALU_Post_Result); //Indica si hubo shift o no
endmodule