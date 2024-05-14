/*
 * This module is the Decoder of the Control Unit
 */ 
module decoder(input logic [1:0] Op,
					input logic [5:0] Funct,
					input logic [3:0] Rd,
					output logic [1:0] FlagW,
					output logic PCS, RegW, MemW,
					output logic MemtoReg, ALUSrc,
					output logic [1:0] ImmSrc, RegSrc, ALUControl,
					output logic NoWrite,
					output logic shift
					);
					//PONER UNA SALIDA MÁS: NOWRITE
					
					
	// Internal signals
	logic [9:0] controls;
	logic Branch, ALUOp;

	//************Main Decoder*******************************+
	always_comb
		casex(Op)
											// Data-processing immediate
			2'b00: 	if (Funct[5])	controls = 10'b0000101001;
											// Data-processing register
						else				controls = 10'b0000001001;
											// LDR
			2'b01: 	if (Funct[0])	controls = 10'b0001111000;
											// STR
						else				controls = 10'b1001110100;
											// B
			2'b10: 						controls = 10'b0110100010;
											// Unimplemented
			default: 					controls = 10'bx;
		endcase
		
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

	//*************ALU Decoder********************+
	always_comb begin
		NoWrite = 1'b0;
		shift = 1'b0;
		if (ALUOp) begin // which DP Instr?
			case(Funct[4:1])
				4'b0100: ALUControl = 2'b00; // ADD
				4'b0010: ALUControl = 2'b01; // SUB
				4'b0000: ALUControl = 2'b10; // AND
				4'b1100: ALUControl = 2'b11; // ORR				
				4'b1010: begin //CMP
							ALUControl = 2'b01;
							NoWrite = 1'b1;
							end
				4'b1101: begin
							ALUControl = 2'bx;
							shift = 1'b1;
							end
				default: ALUControl = 2'bx; // unimplemented
			endcase

			// update flags if S bit is set (C & V only for arith)
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
			end 
			else begin
				ALUControl = 2'b00; // add for non-DP instructions
				FlagW = 2'b00; // don't update Flags
			end
	end
	// PC Logic
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule


/***************************************************************
 * Testbench to test the Alu Encoder
 */ 
module testbench_decoder();
	 logic clk;
    logic [1:0] Op;
    logic [5:0] Funct;
	 logic [3:0] Rd;
    logic [1:0] FlagW;
    logic PCS, RegW, MemW;
    logic MemtoReg, ALUSrc;
    logic [1:0] ImmSrc, RegSrc, ALUControl;
	 logic NoWrite;

	localparam DELAY = 10;
	
	// instantiate device to be tested
	decoder dec(Op, Funct, Rd, FlagW, PCS, RegW, MemW, MemtoReg,
				ALUSrc, ImmSrc, RegSrc, ALUControl, NoWrite);

	// initialize test
	initial
	begin
		Op <= 2'b00;
		Funct[4:1] <= 4'b1100; 
		Funct[0] <= 0;
		#(DELAY*5);
		Op <= 2'b00;
		Funct[4:1] <= 4'b1010; 
		Funct[0] <= 1;
		#(DELAY*5);
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule

