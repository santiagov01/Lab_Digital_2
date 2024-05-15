/*
 * This module is the TOP of the ARM single-cycle processor
 */ 
module top(input logic clk, nreset, nPB,
			  input logic [9:0] switches,
			  output logic [9:0] leds,
			  output logic [6:0] disp4, disp3, disp2, disp1, disp0);

	// Internal signals
	logic reset, PB;
	assign reset = ~nreset;
	assign PB = ~nPB;
	logic [31:0] PC, Instr, ReadData;
	logic [31:0] WriteData, DataAdr;
	logic MemWrite;
	
	// Instantiate instruction memory
	imem imem(PC, Instr);

	// Instantiate data memory (RAM + peripherals)
	dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData, switches, PB, leds, disp4, disp3, disp2, disp1, disp0);

	// Instantiate processor
	arm arm(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
endmodule

/*
 * Testbench to test the peripherals part
 */ 
module testbench_peripherals_top();
	logic clk;
	logic reset, PB;
	logic [9:0] switches, leds;
	logic [6:0] disp4, disp3, disp2, disp1, disp0;

	localparam DELAY = 10;
	
	// instantiate device to be tested
	top dut(clk, reset, PB, switches, leds, disp4, disp3, disp2, disp1, disp0);

	// initialize test
	initial
	begin
		reset <= 0; #(DELAY*20); 
		reset <= 1; 
		
		switches <= 10'b00_0000_1001; #(DELAY*20); //9
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		switches <= 10'b00_0011_0001; #(DELAY*20);//49
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		//R = 58
		switches <= 10'b00_1111_0110; #(DELAY*20); //-10
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		switches <= 10'b00_0011_0001; #(DELAY*20);//49		
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		//R=-39
		switches <= 10'b00_1111_0110; #(DELAY*20); //-10
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		switches <= 10'b00_1110_1100; #(DELAY*20);//-20 creo xd		
		PB <= 1'b0; #(DELAY*10);
		PB <= 1'b1; #(DELAY*10);
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule