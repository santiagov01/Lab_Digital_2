// **********************
// Adder Unit Module
// **********************
module adderunit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;

	// Internal signals to perform the multiplication
	logic sign_sumR;
	logic [7:0] exp_sumR;
	logic [24:0] mantissa_sumR; //****** pendiente modificar el rango
	
	logic [22:0] aux_A, aux_B; //*******Falta revisar bien cuantos bits son
	logic cout;
	
//***********************************************
//				    ADD EXPONENT                    *
//***********************************************
	always_comb begin
		if(dataA[30:23] > dataB[30:23]) begin
			exp_sumR = dataA[30:23] - dataB[30:23];//******¿cual es este numero en decimal?=> Se debe restar  127
			aux_A = dataA[22:0] >> (exp_sumR - 8'd127); //Desplazar el menor
			aux_B = dataB[22:0];
			end
		else if (dataA[30:23] < dataB[30:23]) begin
			exp_sumR = dataB[30:23] - dataA[30:23];
			aux_B = dataB[22:0] >> (exp_sumR - 8'd127);
			aux_A = dataA[22:0];
			end
		else 
			begin
			aux_A = dataA[22:0];
			aux_B = dataB[22:0];
			end
	end
//***********************************************
//				IDENTIFICAR SIGNO                   *
//***********************************************
	always_comb begin
		if(dataA[30:23] > dataB[30:23]) begin
			if(dataA[31])//Cuando es negativo
				sign_sumR = 1; //Resultado negativo
			else
				sign_sumR = 0;
			end	
		else if (dataA[30:23] < dataB[30:23]) begin
			if(dataB[31])
				sign_sumR = 1; 
			else
				sign_sumR = 0;
			end
		else if (dataA[30:23] == dataB[30:23]) begin // exponentes iguales
			if(dataB[31]) //*****Si mantisa A > B .... y A es negativo....
				sign_sumR = 1; 
			else//*****Si mantisa A < B .... y A es negativo....
				sign_sumR = 0;
			end
		end
		//Falta asignar cuando son  iguales ¿que determina el resultado?	
	end
//***********************************************
//				Process: mantissa adder             *
//***********************************************	

	always_comb begin
		if (dataA[31] ^ dataB[31]) //Si son diferentes los signos
				if (dataA[31])
					{cout, mantissa_sumR} = {1’b0, aux_B} + ({1’b0, ~aux_A} + 1’b1);//A negativo
				else
					{cout, mantissa_sumR} = {1’b0, aux_A} + ({1’b0, ~aux_B} + 1’b1); //B negativo
		else begin
				mantissa_sumR = {1'b1, aux_A} + {1'b1, aux_B};
				sign_sumR = dataA[31];  //Mismo signo
			end
	end
	
	// Process: operand validator and result normalizer and assembler
	always_comb begin
		dataR[31] = sign_sumR;//*********
		if (mantissa_sumR[24]) begin
			dataR[30:23] = exp_sumR + 8'd1;
			dataR[22:0] = mantissa_sumR[23:1];
		end else begin
			dataR[30:23] = exp_sumR;
			dataR[22:0] = mantissa_multR[22:0];
		end
	end
endmodule

