// **********************
// Adder Unit Module
// **********************
module adderunit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;

	// Internal signals to perform the multiplication
	logic sign_sumR = 0;
	logic [7:0] exp_sumR = 0;
	logic [23:0] mantissa_sumR = 0; //****** pendiente modificar el rango
	
	logic [22:0] aux_A, aux_B; //*******Falta revisar bien cuantos bits son
	logic cout;
	
	logic [1:0] aux_exp;
//***********************************************
//				    ADD EXPONENT                    *
//***********************************************
	always_comb begin
		//Exponente A mayor que B?
		if(dataA[30:23] > dataB[30:23]) begin 
			//Restar exponentes
			exp_sumR <= dataA[30:23] - dataB[30:23];
			//Desplazar mantisa con exponente menor
			aux_B = dataB[22:0] >> (exp_sumR - 8'd127); 
			aux_A = dataA[22:0];
			end
		else if (dataA[30:23] < dataB[30:23]) begin
			exp_sumR <= dataB[30:23] - dataA[30:23];
			aux_A = dataA[22:0] >> (exp_sumR - 8'd127);
			aux_B <= dataB[22:0];
			end
		else if (dataA[30:23] == dataB[30:23])
			begin
			//exp_sumR <= dataB[30:23];
			aux_A <= dataA[22:0];
			aux_B <= dataB[22:0];
			end
	end
//***********************************************
//				IDENTIFICAR SIGNO                   *
//***********************************************
	always_comb begin
		if(dataA[30:23] > dataB[30:23]) begin
			if(dataA[31])//Cuando es negativo
				sign_sumR <= 1; //Resultado negativo
			else
				sign_sumR <= 0;
			end	
		else if (dataA[30:23] < dataB[30:23]) begin
			if(dataB[31])
				sign_sumR <= 1; 
			else
				sign_sumR <= 0;
			end
		else  begin // exponentes iguales
			if(dataA[31] & dataA[22:0] > dataB[22:0]) //*****Si mantisa A > B .... y A es negativo....
				sign_sumR <= 1; 
			else if(dataB[31] & dataA[22:0] < dataB[22:0])//*****Si mantisa A < B .... y B es negativo....
				sign_sumR <= 1;
			else
				sign_sumR <= 0;
			end
	end
		//Falta asignar cuando son  iguales ¿que determina el resultado?	
//***********************************************
//				Process: mantissa adder             *
//***********************************************	

	always_comb begin
		if (dataA[31] ^ dataB[31]) //Si son diferentes los signos
				if (dataA[31])
					{cout, mantissa_sumR} = {1'b0, aux_B} + ({1'b0, ~aux_A} + 1'b1);//A negativo
				else
					{cout, mantissa_sumR} = {1'b0, aux_A} + ({1'b0, ~aux_B} + 1'b1); //B negativo
		else begin
				{cout, mantissa_sumR} = {1'b1, aux_A} + {1'b1, aux_B};
				//sign_sumR = dataA[31];  //Mismo signo
			end
	end
	
	// Process: operand validator and result normalizer and assembler
	always_comb begin
		dataR[31] = sign_sumR;//*********
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
	logic [31:0] dataA, dataB;
	logic [31:0] dataR;
	logic sign_sumR;
	logic [7:0] exp_sumR;
	logic [23:0] mantissa_sumR; //****** pendiente modificar el rango	
	logic [22:0] aux_A, aux_B; //*******Falta revisar bien cuantos bits son
	logic cout;

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