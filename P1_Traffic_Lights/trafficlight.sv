/* **************************************
	Módulo controlador de tráfico de luces 
	************************************** */
module trafficlight #(FPGAFREQ = 50_000_000, 
   T_GREENMAIN = 18, T_YELLOWMAIN = 4, T_GREENSEC = 10, T_YELLOWSEC = 3, T_GREENPEATON = 5, T_REDPEATON = 2, T_RESET = 3)
   (clk, nreset, main_lights, sec_lights, pea_lights,b_npeaton, solicitud, d_unidades, d_decenas);

	/* Entradas y salidas */
	input logic clk, nreset, b_npeaton;
	output logic [2:0] main_lights;	// rojo, amarillo, verde
	output logic [2:0] sec_lights;	// rojo, amarillo, verde
	output logic [1:0] pea_lights;	// rojo, verde
	output logic [7:0] d_unidades;
	output logic [7:0] d_decenas;
	output logic solicitud = 0;				// LED peaton solicitado


	/* Circuito para invertir señal de reloj */
	logic reset;
	assign reset = ~nreset;
	/*Boton  solicitud peaton*/
	logic b_peaton;    // boton iniciado
	assign b_peaton = ~b_npeaton;
	
	/* Señales internas para contar segundos a partir del reloj de la FPGA */
	localparam FREQDIVCNTBITS = $clog2(FPGAFREQ);	// Bits para contador divisor de frecuencia
	logic [FREQDIVCNTBITS-1:0] cnt_divFreq;	// Contador para generar un (1) segundo 
	localparam SECCNTBITS = $clog2(T_GREENMAIN);		// Bits para el contador de segundos
	logic [SECCNTBITS-1:0] cnt_secLeft;			// Contador de segundos restantes
	logic cnt_timeIsUp;								// Tiempo completado en estado actual
	
	
	
	/* Definición de estados de la FSM y señales internas para estado actual y siguiente */
	typedef enum logic [2:0] {Sreset, Smg, Smy, Ssg, Ssy, Spg, Spr} State;
	State currentState, nextState;
	
	/* Asignacion de leds 7 segmentos para unidades y decenas*/
	logic [3:0] e_unidades, e_decenas;
	
	deco_7seg dec7UNI(e_unidades, d_unidades);
	deco_7seg dec7DEC(e_decenas, d_decenas);
	/* *********************************************************************************************
		Circuito secuencial para actualizar estado actual con el estado siguiente. 
		Se emplea señal de reloj de 50 Mhz.  
		********************************************************************************************* */
	always_ff @(posedge clk, posedge reset) 
		if (reset)
			currentState <= Sreset;
		else 
			currentState <= nextState;
		
		
//	always_ff @(posedge clk, posedge reset) 
//		begin
//		if (b_peaton) //				*** Tal vez hace falta poner condinacional
//			solicitud <= 1'b1;
//		else
//			solicitud <= 1'b0;
//		end
		
	
	
	/* *********************************************************************************************
		Circuito combinacional para determinar siguiente estado de la FSM 
		********************************************************************************************* */
	always_comb begin
		if(cnt_timeIsUp)
			case (currentState)
				Smg:	
					nextState = Smy;
				Smy:	
					nextState = Ssg;
				Ssg:	
					nextState = Ssy;
				Ssy:	
					if (solicitud)   //pregunta si boton esta activo
						nextState = Spg;					
					else 
						nextState = Smg;
					
				Spg:
					nextState = Spr;
					
				Spr:
					nextState = Smg;
				default:		
					nextState = Smg;
			endcase
		else	
			nextState = currentState;
	end	
	
	/* *********************************************************************************************
		Circuito combinacional para manejar las salidas
		********************************************************************************************* */
	always_comb begin
		main_lights = 3'b100;			// Para simplificar cada case
		sec_lights = 3'b100;				// Para simplificar cada case
		pea_lights = 2'b10;			
		case (currentState)
			Sreset: begin 					//Estado Reset
				main_lights = 3'b100;   
				sec_lights = 3'b100;
				pea_lights = 2'b10;
				end
			Smg: 
				main_lights = 3'b001;
			Smy:  
				main_lights = 3'b010;
			Ssg: 
				sec_lights = 3'b001;
			Ssy:  
				sec_lights = 3'b010;
			Spg:
				pea_lights = 2'b01;  //Estado peaton
			Spr:
				pea_lights = 2'b10;
		endcase
	end	

	/* *********************************************************************************************
		Circuito secuencial para el contador de segundos y la visualización en displays
		********************************************************************************************* */
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			cnt_divFreq <= 0;
			cnt_secLeft <= SECCNTBITS'(T_RESET-1);	// Casting #de bits significativos
			cnt_timeIsUp <= 0;
			solicitud <= 0; //Apaga la solicitud
		end else begin
		 // Cambia el estado si se presiona el boton
		 if (currentState == Sreset) 
			solicitud <= 0;
		else if(currentState == Spg)
			solicitud <= 0;
		else if (b_peaton && currentState != Spg && currentState != Sreset) begin    
				solicitud <= 1;
			end
		else if (b_peaton && currentState == Spg) begin
				solicitud <= 0;
			end
		
			cnt_divFreq <= cnt_divFreq + 1'b1;
			cnt_timeIsUp <= 0;
			if (cnt_divFreq == FPGAFREQ-1) begin // ¿Un segundo completado?
				cnt_divFreq <= 0;
				cnt_secLeft <= cnt_secLeft - 1'b1;

				// Determinar si se completaron los segundos del estado correspondiente
				if(cnt_secLeft == 0) begin // Contador == 0 y pasará en este ciclo a modCnt-1
					cnt_timeIsUp <= 1;
					case (currentState)
						Sreset:
							begin
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);

							solicitud <= 0;
							end
						Smg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWMAIN-1);	// Casting
						Smy:
							cnt_secLeft <= SECCNTBITS'(T_GREENSEC-1);	// Casting
						Ssg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWSEC-1);	// Casting
						Ssy:
							begin
								if(solicitud == 1) 	begin	//Revisa si peaton ha solicitado
									cnt_secLeft <= SECCNTBITS'(T_GREENPEATON-1);	// Casting							

									end
								else
									cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);	// Casting
							end
						Spg:
							begin
							cnt_secLeft <= SECCNTBITS'(T_REDPEATON-1);
							solicitud <= 0; //Si se pone en el estado ssy, no alcanza a interpretarlo como 1.
							end
						Spr:
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);
					endcase
				end
			end
		end	
	end
	always_comb begin		
		e_unidades = (cnt_secLeft + 1)%4'b1010;
		e_decenas = (cnt_secLeft + 1)/4'b1010;
	end
endmodule

	

/* ****************
	Módulo testbench 
	**************** */
module testbench();
	/* Declaración de señales y variables internas */
	logic clk, reset, b_peaton, solicitud;
	logic [2:0] main_lights, sec_lights;
	logic [1:0] pea_lights;
	logic [7:0] d_unidades,d_decenas;
	
	localparam FPGAFREQ = 8;
	localparam T_GREENMAIN = 18;
	localparam T_YELLOWMAIN = 3;
	localparam T_GREENSEC = 6;
	localparam T_YELLOWSEC = 2;
	localparam T_GREENPEATON = 4;
	localparam T_REDPEATON = 2;
	localparam T_RESET = 3;
	localparam delay = 20ps;
	
	// Instanciar objeto
	trafficlight #(FPGAFREQ, T_GREENMAIN, T_YELLOWMAIN, T_GREENSEC, T_YELLOWSEC,T_GREENPEATON,T_REDPEATON,T_RESET) tl 
	              (clk, ~reset, main_lights, sec_lights, pea_lights,~b_peaton, solicitud,d_unidades, d_decenas);
	// Simulación
	initial begin
		clk = 0;
		reset = 1;
		#(delay);
		reset = 0;
		#(delay*10);
		reset = 1;
		b_peaton = 1;
		#(delay);
		b_peaton = 0;
		reset = 0;
		#(delay*(T_GREENMAIN+T_YELLOWMAIN+T_GREENSEC+T_YELLOWSEC)*FPGAFREQ*2);
		b_peaton = 1;
		#(delay);
		b_peaton = 0;
		#(delay*(36));
		b_peaton = 1;
		#(delay);
		b_peaton = 0;
		#(delay*(30));
		b_peaton = 1;
		#(delay);
		b_peaton = 0;
		$stop;
	end
	
	// Proceso para generar el reloj
	always #(delay/2) clk = ~clk;
endmodule