/* **************************************
	Módulo controlador de tráfico de luces 
	************************************** */
module trafficlight #(FPGAFREQ = 50_000_000, 
   T_GREENMAIN = 18, T_YELLOWMAIN = 4, T_GREENSEC = 10, T_YELLOWSEC = 3, T_GREENPEATON = 5, T_REDPEATON = 2, T_RESET = 3)
   (clk, nreset, main_lights, sec_lights, pea_lights, sol_light,b_npeaton);

	/* Entradas y salidas */
	input logic clk, nreset, b_npeaton;
	output logic [2:0] main_lights;	// rojo, amarillo, verde
	output logic [2:0] sec_lights;	// rojo, amarillo, verde
	output logic [1:0] pea_lights;	// rojo, verde
	output logic sol_light;				// LED peaton solicitado


	/* Circuito para invertir señal de reloj */
	logic reset;
	assign reset = ~nreset;
	/*Boton  solicitud peaton*/
	logic b_peaton = 1'b0;    // boton iniciado
	//assign b_peaton = ~b_npeaton;
	
	/* Señales internas para contar segundos a partir del reloj de la FPGA */
	localparam FREQDIVCNTBITS = $clog2(FPGAFREQ);	// Bits para contador divisor de frecuencia
	logic [FREQDIVCNTBITS-1:0] cnt_divFreq;	// Contador para generar un (1) segundo 
	localparam SECCNTBITS = $clog2(T_GREENMAIN);		// Bits para el contador de segundos
	logic [SECCNTBITS-1:0] cnt_secLeft;			// Contador de segundos restantes
	logic cnt_timeIsUp;								// Tiempo completado en estado actual
	
	logic solicitud; 							//Señal que indica si se ha solicitado
	
	/* Definición de estados de la FSM y señales internas para estado actual y siguiente */
	typedef enum logic [2:0] {Sreset, Smg, Smy, Ssg, Ssy, Spg, Spr} State;
	State currentState, nextState;
	
	/* *********************************************************************************************
		Circuito secuencial para actualizar estado actual con el estado siguiente. 
		Se emplea señal de reloj de 50 Mhz.  
		********************************************************************************************* */
	always_ff @(posedge clk, posedge reset) 
		if (reset)
			currentState <= Sreset;
		else 
			currentState <= nextState;
		
		
	/*always_ff @(posedge clk, posedge reset) 
		begin
		if (b_peaton) //				*** Tal vez hace falta poner condinacional
			solicitud <= 1'b1;
		else
			solicitud <= 1'b0;
		end*/
		
	
	
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
					if (b_peaton) begin   //pregunta si boton esta activo
						nextState = Spg;
					end
					else begin
						nextState = Smg;
					end
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
			//solicitud <= 1'b0; //Apaga la solicitud
		end else begin
			if (b_npeaton) begin      // Cambia el estado si se preciona el boton
				if (~b_peaton) begin
						b_peaton <= 1'b1;   // Peaton en verde
				end	
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
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);
						Smg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWMAIN-1);	// Casting
						Smy:
							cnt_secLeft <= SECCNTBITS'(T_GREENSEC-1);	// Casting
						Ssg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWSEC-1);	// Casting
						Ssy:
							begin
								if(solicitud) 		//Revisa si peaton ha solicitado
									cnt_secLeft <= SECCNTBITS'(T_GREENPEATON-1);	// Casting
								else
									cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);	// Casting
							end
						Spg:
							cnt_secLeft <= SECCNTBITS'(T_REDPEATON-1);
						Spr:
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);
					endcase
				end
			end
		end	
	end
endmodule


/* ****************
	Módulo testbench 
	**************** */
module testbench();
	/* Declaración de señales y variables internas */
	logic clk, reset;
	logic [2:0] main_lights, sec_lights;

	localparam FPGAFREQ = 8;
	localparam T_GREENMAIN = 8;
	localparam T_YELLOWMAIN = 3;
	localparam T_GREENSEC = 6;
	localparam T_YELLOWSEC = 2;
	localparam delay = 20ps;
	
	// Instanciar objeto
	trafficlight #(FPGAFREQ, T_GREENMAIN, T_YELLOWMAIN, T_GREENSEC, T_YELLOWSEC) tl 
	              (clk, ~reset, main_lights, sec_lights);
	// Simulación
	initial begin
		clk = 0;
		reset = 1;
		#(delay);
		reset = 0;
		#(delay*(T_GREENMAIN+T_YELLOWMAIN+T_GREENSEC+T_YELLOWSEC)*FPGAFREQ*2);

		$stop;
	end
	
	// Proceso para generar el reloj
	always #(delay/2) clk = ~clk;
endmodule