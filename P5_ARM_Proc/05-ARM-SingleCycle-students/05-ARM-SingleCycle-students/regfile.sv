/*
 * This module is the Register File of the Datapath Unit
 */ 
module regfile(input logic clk,
					input logic we3,
					input logic [3:0] ra1, ra2, wa3, //Entradas de registros
					input logic [31:0] wd3, r15,
					output logic [31:0] rd1, rd2);

	// Internal signals
	logic [31:0] rf[14:0]; //No son 16 registros porque hace falta el R15 
									//(Primero se le tiene que sumar 8) 	
	// Three ported register file
	// Write third port on rising edge of clock
	always_ff @(posedge clk)
		if (we3) rf[wa3] <= wd3; //Escritura
		
	// Read two ports combinationally
	// register 15 reads PC + 8 instead
	assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];//Lectura
	assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];
endmodule