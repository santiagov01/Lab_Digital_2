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
	LDR R1, =BASEADDRIO
	LDR R1, [R1]
	
	SUB R2, R15, R15
LOOP:
	LDR R3, [R1, #SWI_OFFSET]
	SUBS R12, R2, R3 //Comparar
	BLS WriteToLeds
	SUB R2, R15, R15 //Reincia
	
WriteToLeds:
	STR R2, [R1]
	ADD R2, R2, #1
	B Loop //Porque se puede dar de que el usario presione suiche
	

.data
BASEADDRIO: .DC.L 0xFF200000
ALLONES: .DC.L 0x3FF
