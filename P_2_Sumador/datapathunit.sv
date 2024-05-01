// ******************** 
// Datapath Unit Module
// ******************** 
module datapathunit (clk, reset, enter, inputdata,
						   loaddata, inputdata_ready,
						   disp3, disp2, disp1, disp0);
	input logic  clk, reset, enter;
	input logic  [7:0] inputdata;
	input logic  loaddata;
	output logic inputdata_ready;
	output logic [6:0] disp3, disp2, disp1, disp0;

	// Internal signals and module instantiation for multiplier unit
	logic [31:0] dataA, dataB, dataR;
	adderunit add0 (dataA, dataB, dataR);
	
	// Internal signals and module instantiation for peripherals unit
	peripherals p0 (clk, reset, enter, inputdata, loaddata, inputdata_ready, dataA, dataB, dataR, disp3, disp2, disp1, disp0);
endmodule

module testbench_data();
	/* Declaración de señales y variables internas */

	localparam delay = 20ps;
	
	// Instanciar objeto

	logic  clk, reset, enter;
	logic  [7:0] inputdata;
	logic  loaddata;
	logic inputdata_ready;
	logic [6:0] disp3, disp2, disp1, disp0;

	// Internal signals and module instantiation for multiplier unit
	logic [31:0] dataA, dataB, dataR;
	
	datapathunit data (clk, reset, enter, inputdata,
						   loaddata, inputdata_ready,
						   disp3, disp2, disp1, disp0);
	
	// Simulación
	initial begin
		clk = 0;	
		reset = 1;
		#delay
		reset = 0;
		//A
		#delay
		loaddata = 1;
		inputdata = 8'h40;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'hE0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'h00;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'h00;
		#delay
		enter = 1;
		#delay
		enter = 0;
		
		//B
		#delay
		inputdata = 8'hC0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'hE0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'h10;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		inputdata = 8'h00;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		
		//R
		#delay
		loaddata = 0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		enter = 1;
		#delay
		enter = 0;
		#delay
		
		$stop;
	end
	
	// Proceso para generar el reloj
	always #(delay/2) clk = ~clk;
endmodule
