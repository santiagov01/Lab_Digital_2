/*
 * This module is the Data Memory of the ARM single-cycle processor
 * It corresponds to the RAM array and some external peripherals
 */ 
		module dmem(input logic clk, we, input logic [31:0] a, wd, output logic [31:0] rd,
            input logic [9:0] switches, input logic PB, output logic [9:0] leds, 
				output logic [7:0] disp4, disp3, disp2, disp1, disp0);
	// Internal array for the memory (Only 64 32-words)
	logic [31:0] RAM[63:0];
	logic [7: 0] display;  
	logic [3:0] ABR; 

	initial
		// Uncomment the following line only if you want to load the required data for the peripherals test
		//$readmemh("dmem_to_test_peripherals.dat",RAM);
		
      $readmemh("D:/Estudio/OneDrive - Universidad de Antioquia/Estudio/Materias/S6/Digital 2/Laboratorio/Repositorio/Lab_Digital_2/P5_ARM_Proc/05-ARM-SingleCycle-students/05-ARM-SingleCycle-students/dmem_to_test_peripherals.dat",RAM);
		// Uncomment the following line only if you want to load the required data for the program made by your group
		// $readmemh("dmem_made_by_students.dat",RAM);
	
	// Process for reading from RAM array or peripherals mapped in memory
	always_comb
			
		if (a == 32'hC000_0000)			// Read from Switches (10-bits)
			rd = {22'b0, switches};
		else if (a == 32'hC000_0010)
			rd = {31'b0, PB};
		else									// Reading from 0 to 252 retrieves data from RAM array
			rd = RAM[a[31:2]]; 			// Word aligned (multiple of 4)
	
	always_ff @(posedge clk) begin
		if (we)
			if (a == 32'hC000_0004)	// Write into LEDs (10-bits)
				leds <= wd[9:0];
			else if (a == 32'hC000_0008)
				display <= wd[7:0]; // Write into displays ()
			else if (a == 32'hC000_000C)	// Write to letter
				ABR = wd[3:0]; // 00, 01 , 10
			else	
				RAM[a[31:2]] <= wd;
	end	
	//Enter 8bit switches, letter state, and displays as output
	displays d(display, ABR, disp4, disp3, disp2, disp1, disp0);
endmodule