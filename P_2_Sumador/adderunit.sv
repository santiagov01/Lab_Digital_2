	// **********************
// Adder Unit Module
// **********************
module adderunit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;

	// Internal signals to perform the multiplication
	logic [7:0] exp_sumR, exp_sumR_final,dif;//dif: restar los exponentes para la diferencia
	logic [25:0] mantisaux_A, mantisaux_B; //Se agrega 001 Se le debe agregar 001 (signo_carry_1.)
	logic [25:0] mantisanorm_A, mantisanorm_B; //Mantisa normalizada si exponentes son diferentes
	logic [25:0] negative_A, negative_B; //Mantisa negativa
	logic [25:0] mantissa_sumR = 0; //Resultado de sumar
	logic [25:0] mantissa_sumR_check = 0;//Actualizar mantisa luego de sumar
	
	logic [22:0] special_mantisa = 0;//Mantisa para casos especiales
	logic [7:0] special_exp = 0;//Exponente en casos especiales
	logic sign_special = 0; //Signo para casos especiales
	
	logic [25:0] mantisa_f_aux; //por si es necesaria 	azando
	logic [22:0] frac; //para utilizar en el 	azamiento final a izquierda
	logic [22:0] mantisaFinal;
	logic cout;
	logic [1:0] lastbits;
	
	logic [1:0] aux_exp;
	
	logic [4:0] desplz; //Cantidad de espacios para desplazar mantisa final 
	
	logic special_case = 0; //
	
	logic [30:0] inf;
	logic [30:0] nan;
	logic [31:0] Rspecial = 0;
	logic ceroA, ceroB, infApos, infBpos, infAneg, infBneg, NaNA, NaNB;
	

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
		dif = 0;
		//Comparar exponentes
		if(dataA[30:23] > dataB[30:23]) begin 
			//Restar exponentes
			dif = dataA[30:23] - dataB[30:23];
			exp_sumR = dataA[30:23];
			//Desplazar mantisa con exponente menor
			mantisanorm_B = mantisaux_B >> (dif); 
			mantisanorm_A = mantisaux_A;
			end
		else if (dataA[30:23] < dataB[30:23]) begin
			dif = dataB[30:23] - dataA[30:23];
			exp_sumR = dataB[30:23];
			mantisanorm_A = mantisaux_A >> (dif); 
			mantisanorm_B = mantisaux_B;
			end
		//exponentes iguales, se deja igual
		else if (dataA[30:23] == dataB[30:23]) 
			begin
			exp_sumR = dataB[30:23];
			mantisanorm_A = mantisaux_A;
			mantisanorm_B = mantisaux_B;
			end
	end

//***********************************************
//				Process: mantissa adder             *
//***********************************************	

	always_comb begin
		negative_A = (~mantisanorm_A + 1'b1);//A negativo
		negative_B = (~mantisanorm_B + 1'b1);//B negativo
		if (dataA[31] ^ dataB[31]) //Si son diferentes los signos
				begin
				if (dataA[31])
				//El ultimo bit corresponde al signo, y los dos siguientes se revisan para ajustar exponente					
					mantissa_sumR = mantisanorm_B + negative_A;
				else					
					mantissa_sumR = mantisanorm_A + negative_B;
				end
		else if( dataA[31] & dataB[31]) // si son ambos negativos
				mantissa_sumR = negative_A + negative_B;
		else begin //si son ambos positivos
				mantissa_sumR = mantisanorm_A + mantisanorm_B;
			end
	end
//***********************************************
//				CASOS ESPECIALES                    *
//***********************************************	
always_comb begin
	special_case = 0;
	special_mantisa = 0;
	special_exp = 0;
	sign_special = 0;
	Rspecial = 0;
	//Asignar valor infinito. (No estoy mirando signo, solo mantisa y exponente porque son lo mismo)
	inf = {8'b1,23'b0}; //1111111000000000000000000000
	//primer caso especial
	 ceroA = (dataA[30:23]==0) & (dataA[22:0]==0);
	 ceroB = (dataB[30:23]==0) & (dataB[22:0]==0);
	 infApos = (dataA[31]==0) & (dataA[30:23] == 8'b11111111) & (dataA[22:0] == 0);
	 infBpos = (dataB[31]==0) & (dataB[30:23] == 8'b11111111) & (dataB[22:0] == 0);
	 infAneg = (dataA[31]==1) & (dataA[30:23] == 8'b11111111) & (dataA[22:0] == 0);
	 infBneg = (dataB[31]==1) & (dataB[30:23] == 8'b11111111) & (dataB[22:0] == 0);
	 NaNA = (dataA[30:23] == 8'b11111111) & (dataA[22:0] != 0);
	 NaNB = (dataB[30:23] == 8'b11111111) & (dataB[22:0] != 0);
	 
	if((dataA[31] ^ dataB[31]) & (dataA[30:0] == dataB[30:0]) & (dataA[30:23] != 8'b11111111) & (dataB[30:23] != 8'b11111111)) begin
		special_case = 1;
		Rspecial = 32'h00000000;
		end
		else if (ceroA & ceroB) begin
		special_case = 1;

		Rspecial = 32'h00000000;
		end 
		else if (ceroA) begin
		special_case = 1;
		Rspecial = dataB;
		end
		else if(ceroB) begin
		Rspecial = dataA;
		special_case = 1;
		end
		
		
	//caso NaN
	else if( (infApos & infBneg) || (infAneg & infBpos))begin

		special_case = 1;
		Rspecial = 32'hFFFFFFFF;
		end
	else if(NaNA) begin

		special_case = 1;
		Rspecial = dataA;
		end
		else if(NaNB) begin

		special_case = 1;
		Rspecial = dataB;
		end		
	
	else if( (infApos & ~infBpos) || (~infApos & infBpos) || (infApos & infBpos))begin //Infinito positivo
			special_case = 1;
			Rspecial = 32'h7F800000;

		end
	else if  ( (infAneg & ~infBneg) || (~infAneg & infBneg) || (infAneg & infBneg))begin //Infinito negativo
			special_case = 1;
			Rspecial = 32'hFF800000;

		end
		else
		special_case = 0;
	

end

//if( Infinito...., - infitino, nan...)
//if(


//***********************************************
//		Complemento a 2 si es negativo            *
//***********************************************
	always_comb begin
		mantissa_sumR_check = 0;
		if (mantissa_sumR[25])
			mantissa_sumR_check[24:0] = (~(mantissa_sumR[24:0]) + 1'b1); //complemento a 2
		else
			mantissa_sumR_check = mantissa_sumR;			
	end
//***********************************************
//		AJUSTAR MANTISA LUEGO DE SUMA	            *
//***********************************************
	always_comb begin		
		lastbits = mantissa_sumR_check[24:23];
		frac = mantissa_sumR_check[22:0];
		exp_sumR_final = exp_sumR;
		mantisaFinal = 0;
		desplz =0 ; 
		case(lastbits)
			2'b01: mantisaFinal = mantissa_sumR_check[22:0]; //exponente no cambiaría
			2'b00:begin // revisar hasta encontrar 1 y desplazar mantisa y restar a exponentes
					
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
						23'b00000000000000000000001: desplz = 23;
						default:  desplz = 24; //falta revisar el caso donde todo es cero, caso especial ?						
					endcase
					mantisaFinal = frac << desplz;
					exp_sumR_final= exp_sumR - desplz;
				end
				
				default: 
					begin// 11.xxx ,,, o 10.xxx ,,, => 1.1xxx ó 1.0xxx
					mantisaFinal = mantissa_sumR_check[23:1];
					exp_sumR_final = exp_sumR +8'd1; //Se suma 1 al exponente
					end
				 
		endcase
	end

	
	// Process: operand validator and result normalizer and assembler
	always_comb begin
		if(special_case) begin //SI se presentan casos especiales....

			dataR = Rspecial;
			end
		else if((exp_sumR_final == 8'b11111111) & (mantisaFinal != 0))begin
				if(mantissa_sumR[25])
					dataR = 32'hFF800000; //si suma me da mayor...indicar que es infinito
				else
					dataR = 32'h7F800000;			
			end
		else begin
			dataR[31] = mantissa_sumR[25];//*********
			dataR[30:23] = exp_sumR_final;
			dataR[22:0] = mantisaFinal;
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

	localparam delay = 1ns;
	
	// Instanciar objeto
	adderunit au (dataA, dataB, dataR);
	// Simulación
	initial begin
		dataA = 32'b01000000011000000000000000000000;
		dataB = 32'b01000000010000000000000000000000;
		#delay;
		dataA = 32'h40B00000;
		dataB = 32'h40880000;
		#delay;
		dataA = 32'h40E00000;
		dataB = 32'hC0880000;
		#delay;
		dataA = 32'h40E00000;//B5000000
		dataB = 32'hC0E01000;
		#delay;
		dataA = 32'h40E00000;//B5000000
		dataB = 32'hC0E00001;
		#delay;
		dataA = 32'h40E00000;//C3F68000
		dataB = 32'h43FA0000;
		#delay;
		dataA = 32'h40E00000;//B5800000
		dataB = 32'hC0E00002;
		#delay;
		dataA = 32'h00000000;
		dataB = 32'hC0E00002;
		#delay;
		dataA = 32'h40E00002; //0000000
		dataB = 32'hC0E00002;
		#delay;
		
		dataA = 32'h7F7FFFFF;//7F800000  Infinito
		dataB = 32'h7F000400;
		#delay;
		dataA = 32'h7F800000;//7F800000
		dataB = 32'h3C000400;
		#delay;
		dataA = 32'hFF800000;//FF800000 -Infinito
		dataB = 32'h7C400400;
		#delay;
		dataA = 32'hFF800000;//FF800000
		dataB = 32'hFF800000;
		#delay;
		dataA = 32'h7F800000;//7F800000
		dataB = 32'h7F800000;
		#delay;
		
		dataA = 32'h7F800000; //FFFFFFFF
		dataB = 32'hFF800000;
		#delay;
		dataA = 32'h00000000; //Cero
		dataB = 32'h00000000;
		#delay;
		dataA = 32'h00400000; //Num + cero
		dataB = 32'h00000000;
		#delay;
		dataA = 32'h00008000;
		dataB = 32'h00000000;
		#delay;
		dataA = 32'hC0E00000;//C1600800
		dataB = 32'hC0E01000;
		#delay;
		dataA = 32'hC0FFFFFF;//C17008F0
		dataB = 32'hC0E011E0;
		#delay;
		dataA = 32'h6FFFFFFF;//6FFFFFFF
		dataB = 32'hDFE011E0;
		#delay;
		dataA = 32'h00FFFFFF;//DFF023C2
		dataB = 32'hDFF023C2;
		#delay;
		dataA = 32'h40FFFFFF;//417FFFFE
		dataB = 32'h40FFFFFE;
		#delay;
		dataA = 32'hC0FFFFFF;//C1780000
		dataB = 32'hC0F00000;
		#delay;
		dataA = 32'hC0FC0000;//C1760000
		dataB = 32'hC0F00000;
		#delay;
		dataA = 32'hC7FC0000;//C7FC03A0
		dataB = 32'hC0E80000;
		#delay;
		dataA = 32'hE0740000;//E0EC0000
		dataB = 32'hE0640000;
		#delay;
		dataA = 32'hC0740000;//C0F80000
		dataB = 32'hC07C0000;
		#delay;
		$stop;
	end
	
	// Proceso para generar el reloj
	//always #(delay/2) clk = ~clk;
endmodule