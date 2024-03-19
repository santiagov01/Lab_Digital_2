// **********************
// Adder Unit Module
// **********************
module adderunit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;

	// Internal signals to perform the multiplication
	logic sign_sumR = 0;
	logic [7:0] exp_sumR, exp_sumR_final;
	logic [25:0] mantissa_sumR = 0; //****** pendiente modificar el rango
	logic [25:0] mantissa_sumR_check = 0;
	logic [25:0] mantisaux_A, mantisaux_B; //*******Falta revisar bien cuantos bits son
	logic [25:0] mantisanorm_A, mantisanorm_B; //*******Falta revisar bien cuantos bits son
	
	logic [25:0] mantisa_f_aux; //por si es necesaria 	azando
	logic [22:0] frac; //para utilizar en el 	azamiento final a izquierda
	logic [22:0] mantisaFinal;
	logic cout;
	logic [1:0] lastbits;
	logic [22:0] first_one_position;
	logic [1:0] aux_exp;
	
	logic [4:0] desplz; //Cantidad de espacios para desplazar mantisa final 
	
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
//				Process: mantissa adder             *
//***********************************************	

	always_comb begin
		if (dataA[31] ^ dataB[31]) //Si son diferentes los signos
				if (dataA[31])
				//El ultimo bit corresponde al signo, y los dos siguientes se revisan para ajustar exponente
					mantissa_sumR = mantisanorm_B + (~mantisanorm_A + 1'b1);//A negativo
				else
					mantissa_sumR = mantisanorm_A + (~mantisanorm_B + 1'b1); //B negativo
		else begin
				mantissa_sumR = mantisanorm_A + mantisanorm_B;
				//sign_sumR = dataA[31];  //Mismo signo
			end
	end
	
//***********************************************
//		Complemento a 2 si es negativo            *
//***********************************************
	always_comb begin
		mantissa_sumR_check = 0;
		if (mantissa_sumR[25])
			mantissa_sumR_check = ~mantissa_sumR + 1'b1;
		else
			mantissa_sumR_check = mantissa_sumR;			
	end
//***********************************************
//		AJUSTAR MANTISA LUEGO DE SUMA	            *
//***********************************************
	always_comb begin
		first_one_position = 0;
		lastbits = mantissa_sumR_check[24:23];
		frac = mantissa_sumR_check[22:0];
		exp_sumR_final = exp_sumR;
		mantisaFinal = 0;
		desplz =0 ; 
		case(lastbits)
			2'b01: mantisaFinal = mantissa_sumR_check[22:0]; //exponente no cambiaría
			2'b00:begin // revisar hasta encontrar 1 y desplazar mantisa y restar a exponente -127
					
					casez(frac)
						23'b1??????????????????????: desplz =  1;
						23'b01?????????????????????: desplz = 2;
						23'b001????????????????????: desplz = 3;
						23'b0001???????????????????: desplz = 4;
						23'b00001??????????????????: desplz = 5;
						23'b000001?????????????????: desplz = 6;
						23'b0000001????????????????: desplz = 7;
						23'b00000001???????????????: desplz = 8;
						23'b000000001??????????????: desplz = 9;
						23'b0000000001?????????????: desplz = 10;
						23'b00000000001????????????: desplz = 11;
						23'b000000000001???????????: desplz = 12;
						23'b0000000000001??????????: desplz = 13;
						23'b00000000000001?????????: desplz = 14;
						23'b000000000000001????????: desplz = 15;
						23'b0000000000000001???????: desplz = 16;
						23'b00000000000000001??????: desplz = 17;
						23'b000000000000000001?????: desplz = 18;
						23'b0000000000000000001????: desplz = 19;
						23'b00000000000000000001???: desplz = 20;
						23'b000000000000000000001??: desplz = 21;
						23'b0000000000000000000001?: desplz = 22;
						default:  desplz = 23; //falta revisar el caso donde todo es cero, caso especial ?						
					endcase
					mantisaFinal = frac << desplz;
					exp_sumR_final= exp_sumR - 8'b1111_1111 - desplz;
				end
				
				default: 
					begin
					mantisaFinal = mantissa_sumR_check[23:1];// 11.xxx ,,, o 10.xxx ,,, => 1.1xxx ó 1.0xxx
					exp_sumR_final = exp_sumR +1'b1; //Se suma 1 al exponente
					end
				 //también serviría el corrimiento a izquierda??
		endcase
	end

	
	// Process: operand validator and result normalizer and assembler
	always_comb begin
		dataR[31] = mantissa_sumR_check[25];//*********
		if (mantissa_sumR_check[23]) begin
			dataR[30:23] = exp_sumR + 8'd1;
			dataR[22:0] = mantissa_sumR_check[23:1];
		end else begin
			dataR[30:23] = exp_sumR;
			dataR[22:0] = mantissa_sumR_check[22:0];
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
	logic [7:0] exp_sumR;
	logic [25:0] mantissa_sumR = 0;
	logic [25:0] mantissa_sumR_check = 0; //****** pendiente modificar el rango
	
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