.equ SWI_OFFSET,0x40
.global _start
_start:
/*
	LDR R1, =BASEADDRIO //NO funciona en procesador porque LDR solo lee de dataMemory, y este dato está guardado en Instruction Memory
	LDR R1, [R1]
	
	LDR R0, =ALLONES
	LDR R0, [R0]
	STR R0, [R1]
*/
//----------------------------------------
/*
LDR R1, =BASEADDRIO
	LDR R1, [R1]
LOOP:
	LDR R0, [R1, #0x40]
	STR R0, [R1]
	B LOOP
*/
//---------------------------
/*
	LDR R1, =BASEADDRIO
	LDR R1, [R1]
	
	SUB R2, R15, R15
LOOP:
	LDR R3, [R1, #SWI_OFFSET]
	SUBS R12, R2, R3 //Comparar
	BLS WriteToLeds
	SUB R2, R15, R15 //Reincia
	
WriteToLeds:
	STR R2, [R1] //leds
	LDR R3, =TIMEDELAY
	LDR R3, [R3]
Delay:
	SUBS R3, R3, #1
	BNE Delay
	ADD R2, R2, #1
	
	B LOOP //Porque se puede dar de que el usario presione suiche
	*/
//----------------------------------------------------
//Version con uso correcto de instruc memory and data memory
/*
	SUB R0, R15, R15 //r0 apunta a memoria de datos
	LDR R1, [R0, #0] //En este caso le doy la direccion de suiches(ya no hay offset)
	
	SUB R2, R15, R15
LOOP:
	LDR R3, [R1, #0]
	SUBS R12, R2, R3 //Comparar
	BLS WriteToLeds
	SUB R2, R15, R15 //Reincia
	
WriteToLeds:
	STR R2, [R1, #4] //LEDS
	LDR R3, [R0, #4]
Delay:
	SUBS R3, R3, #1
	BNE Delay
	ADD R2, R2, #1
	
	B LOOP //Porque se puede dar de que el usario presione suiche
*/
.data
BASEADDRIO: .DC.L 0xFF200000
ALLONES: .DC.L 0x3FF
TIMEDELAY: .DC.L  0x2FAF08
