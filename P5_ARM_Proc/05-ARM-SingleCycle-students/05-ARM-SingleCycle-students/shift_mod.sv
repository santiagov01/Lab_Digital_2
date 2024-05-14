/*
 * This module is the shifter block
 */ 
module shift_mod(input logic [31:0]WriteData, 
				input logic [6:0] Instr,
				output logic [31:0] outShift);

logic [4:0] shamt5;
logic [1:0] sh;

assign shamt5 = Instr[6:2];
assign sh = Instr[1:0];

//*****
	always_comb
		case(sh)
			2'b00:outShift = WriteData << shamt5;//LSL
			2'b01:outShift = WriteData >> shamt5;//LSR
			//ASR
			2'b10:outShift = (WriteData[31] == 1) ? (WriteData >> shamt5 | ({32{1'b1}} << 32 - shamt5)) : (WriteData >> shamt5);
			2'b11:outShift = (WriteData >> shamt5) | (WriteData << (32 -  shamt5));//ROR
		endcase
endmodule


/***************************************************************
 * Testbench to test the Inmediate Shifter 
 */ 
module tb_shifter();
	logic clk;
    logic [31:0] WriteData,outShift;
    logic [6:0] Instr;
    localparam DELAY = 10;
	
	// instantiate device to be tested
	shift_mod shift(WriteData, Instr, outShift);

	// initialize test
	initial
	begin
		WriteData <= 32'hFF1C10E7;
		Instr[6:2] <= 5'd17;
        Instr[1:0] <= 2'b01;
		#(DELAY*5);
		WriteData <= 32'hFF1C10E7;
		Instr[6:2] <= 5'd21;
        Instr[1:0] <= 2'b11;
		#(DELAY*5);
        WriteData <= 32'hFF1C10E7;
		Instr[6:2] <= 5'd3;
       Instr[1:0] <= 2'b10;
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