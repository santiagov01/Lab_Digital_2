// **********************
// Adder Unit Module
// **********************
module adderunit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;

	// Internal signals to perform the multiplication
	logic sign_sumR = 0;
	logic [7:0] exp_sumR;
	logic [25:0] mantissa_sumR = 0; //****** pendiente modificar el rango
	
	logic [25:0] mantisaux_A, mantisaux_B; //*******Falta revisar bien cuantos bits son
	logic [25:0] mantisanorm_A, mantisanorm_B; //*******Falta revisar bien cuantos bits son
	logic cout;
	
	logic [1:0] aux_exp;
//***********************************************
//				    ADD EXPONENT                    *
//***********************************************
	always_comb begin
		//Exponente A mayor que B?
		mantisaux_A = {3'b001,dataA[22:0]};
		mantisaux_B = {3'b001,dataB[22:0]};
		
		mantisanorm_A = 0;
		mantisanorm_B = 0;
		exp_sumR = 0;
		if(dataA[30:23] > dataB[30:23]) begin 
			//Restar exponentes
			exp_sumR = dataA[30:23] - dataB[30:23];
			//Desplazar mantisa con exponente menor
			mantisanorm_B = mantisaux_B[22:0] >> (exp_sumR); 
			mantisanorm_A = mantisaux_A;
			end
		else if (dataA[30:23] < dataB[30:23]) begin
			exp_sumR = dataA[30:23] - dataB[30:23];
			mantisanorm_A = mantisaux_A[22:0] >> (exp_sumR); 
			mantisanorm_B = mantisaux_B;
			end
		else if (dataA[30:23] == dataB[30:23])
			begin
			//exp_sumR <= dataB[30:23];
			mantisanorm_A = mantisaux_A;
			mantisanorm_B = mantisaux_B;
			end
	end
//***********************************************
//				IDENTIFICAR SIGNO                   *
//***********************************************


//***********************************************
//				Process: mantissa adder             *
//***********************************************	

	always_comb begin
		if (dataA[31] ^ dataB[31]) //Si son diferentes los signos
				if (dataA[31])
					mantissa_sumR = mantisanorm_B + (~mantisanorm_A + 1'b1);//A negativo
				else
					mantissa_sumR = mantisanorm_A + (~mantisanorm_B + 1'b1); //B negativo
		else begin
				mantissa_sumR = mantisanorm_A + mantisanorm_B;
				//sign_sumR = dataA[31];  //Mismo signo
			end
	end
	
	// Process: operand validator and result normalizer and assembler
	always_comb begin
		dataR[31] = mantissa_sumR[25];//*********
		if (mantissa_sumR[23]) begin
			dataR[30:23] = exp_sumR + 8'd1;
			dataR[22:0] = mantissa_sumR[23:1];
		end else begin
			dataR[30:23] = exp_sumR;
			dataR[22:0] = mantissa_sumR[22:0];
		end
	end
endmodule

/* ****************
	Módulo testbench 
	**************** */
module testbench();
	/* Declaración de señales y variables internas */
	logic [31:0] dataA, dataB,dataR;
	logic sign_sumR = 0;
	logic [7:0] exp_sumR;00000000000000000000000
	logic [24:0] mantissa_sumR = 0; //****** pendiente modificar el rango
	
	logic [25:0] mantisaux_A, mantisaux_B; //*******Falta revisar bien cuantos bits son
	logic [25:0] mantisanorm_A, mantisanorm_B; //*******Falta revisar bien cuantos bits son
	logic cout;
	
	logic [1:0] aux_exp;

	localparam delay = 20ps;
	
	// Instanciar objeto
	adderunit au (dataA, dataB, dataR);
	// Simulación
	initial begin
		dataA = 32'b01000000011000000000000000000000;
		dataB = 32'b01000000010000000000000000000000;
		$stop;
	end
	
	// Proceso para generar el reloj
	//always #(delay/2) clk = ~clk;
endmodule