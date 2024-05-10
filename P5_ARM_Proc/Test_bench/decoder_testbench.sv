/*
 * Testbench to test the peripherals part
 */ 
module testbench_decoder();
    logic [1:0] Op,
    logic [5:0] Funct,
	logic [3:0] Rd,
    logic [1:0] FlagW,
    logic PCS, RegW, MemW,
    logic MemtoReg, ALUSrc,
    logic [1:0] ImmSrc, RegSrc, ALUControleds;

	localparam DELAY = 10;
	
	// instantiate device to be tested
	decoder dut_2(clk, reset, switches, leds);

	// initialize test
	initial
	begin
		reset <= 0; #DELAY; 
		reset <= 1; 
		
		Op <= 10'd4; #(DELAY*2000);
		
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule