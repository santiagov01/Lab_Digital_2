/***************************************************************
 * Testbench to test the Inmediate Shifter 
 */ 
module tb_shifter();
	logic clk;
    logic [31:0] WriteData,outShift;
    logic [6:0] Instr;
    localparam DELAY = 10;
	
	// instantiate device to be tested
	shift_mod shift(Write, Instr, outShift);

	// initialize test
	initial
	begin
		WriteData <= 32'hFF1C10E7;
		Instr[6:2] <= 5'd17;
        Instr[1:0] <= 2'b00;
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