/*
 * Testbench to test the peripherals part
 */ 
module testbench_decoder();
    logic [1:0] Op;
    logic [5:0] Funct;
	logic [3:0] Rd;
    logic [1:0] FlagW;
    logic PCS, RegW, MemW;
    logic MemtoReg, ALUSrc;
    logic [1:0] ImmSrc, RegSrc, ALUContro;
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
		#DELAY
		Op <= 2'b00;
		Funct[4:1] <= 4'b1010; 
		Funct[0] <= 1;
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule
