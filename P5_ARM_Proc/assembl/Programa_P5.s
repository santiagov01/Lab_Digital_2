.global _start
_start:
// 
//

	MOV R0, #0// contador de estados.
	LDR R1, [R0]		// Cargar en R1 el valor de la direccion de switches
	MOV R12, #0
	
Debouncing: // Loop de Debouncing, solo cambia de estado cuando se mueva el pulsador.
	
	CMP R0, #1 // Si Se esta ingresando A o B, se actualizan los led (R0 es 0/1).
	BLE Current_leds
	B Not_leds
	
Current_leds: 
	
	LDR R2, [R1]
	LSL R2, R2, #24    // Desplaza los bits de R4 24 posiciones a la izquierda
    ASR R2, R2, #24
	STR R2, [R1, #4]   // Guarda en LEDs el valor de Switches
	STR R2, [R1, #8]   // Guarda en el display el valor de Switches
	STR R12, [R1, #12]   // Guarda en el display LA LETRA
Not_leds:// si ya se ingreso A y B, se muestran LED de Resultado (R0 > 2).

	LDR R3, [R1,#16] // cargo en R3 el valor que tenga en PushBotton (sumo offset)

    CMP R3, #0            // Comprueba si el botón no esta presionado
    MOVEQ R12, #0          // Si no está presionado, resetea el estado anterior
	
    BEQ Debouncing     // Si no está presionado, mantiene el mismo estado
	
    CMP R12, #1            // Verifica si el estado anterior indica que ya estaba presionado
    BEQ Debouncing     // Si ya estaba presionado, ignora esta lectura
						// De lo contrario Actualiza estado 
    MOV R12, #1            // Actualiza el estado anterior a presionado

	CMP R0,#0 // si estoy Cargando A (R0 = '0').
	BEQ LoadA // 
		
	CMP R0, #1 // si estoy cargando B (R0 = '1'),
	BEQ LoadB
	
	CMP R0 ,#3 // Se reinicia la maquina de estados.
	BEQ Reset
	
	B Debouncing
	
LoadA:
	//LDR R4, [R1]
	MOV R4, R2
	ADD R0, R0,#1
	B Debouncing
		
LoadB:
	//LDR R5, [R1]
	MOV R5, R2
	ADD R0, R0, #1
	B Operar


Operar:
	// Suma de numeros con signo de 8Bits
	//LSL R4, R4, #24    // Desplaza los bits de R4 24 posiciones a la izquierda
    //ASR R4, R4, #24    // Desplaza aritméticamente los bits 24 posiciones a la derecha, extendiendo el signo

    //R5: Extender el signo de 8 bits a 32 bits
    //LSL R5, R5, #24    // Desplaza los bits de R5 24 posiciones a la izquierda
    //ASR R5, R5, #24    // Desplaza aritméticamente los bits 24 posiciones a la derecha, extendiendo el signo

    //Sumar los valores
    ADD R8, R4, R5     // Suma R4 y R5, guarda el resultado en R6
	
	STR R8 , [R1, #4] // actualiza leds
	STR R2, [R1, #8]  // actualiza display
	STR R12, [R1, #12]   // Guarda en el display LA LETRA
	ADD R0, R0, #1 // pasa a estado 3
	b Debouncing

Reset:
	MOV R0, #0
	B Debouncing


	
.data

Switches: .DC.L 0xC0000000
