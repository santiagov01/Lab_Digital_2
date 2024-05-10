/*
 * This module is the Instruction Memory of the ARM single-cycle processor
 */ 
module imem(input logic [31:0] a, output logic [31:0] rd);
	// Internal array for the memory (Only 64 32-words)
	logic [31:0] RAM[255:0];

	// The following line loads the program instruction
	// Be careful to have a program longer than the memory available
	initial
		// Uncomment the following line only if you want to load the code given to check peripherals
		//$readmemh("D:/Estudio/OneDrive - Universidad de Antioquia/Estudio/Materias/S6/Digital 2/Laboratorio/Repositorio/Lab_Digital_2/P5_ARM_Proc/05-ARM-SingleCycle-students/05-ARM-SingleCycle-students/imem_to_test_peripherals.dat",RAM);
		$readmemh("imem_to_test_peripherals.dat",RAM);
		// Uncomment the following line only if you want to load the code made by your group
		// $readmemh("imem_made_by_students.dat",RAM);

	assign rd = RAM[a[31:2]]; // word aligned
endmodule


