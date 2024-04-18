.global _start
_start:
	.equ MAXN, 50 //Maximo de terminos solicitados
	.equ M, 90 //Cantidad de terminos a generar
MOV R0, #M
LDR R1, =FIBO

BL Fibo

B Final
Fibo:
	MOV R2, #0
	MOV R3, #0
	STR R2, [R1], #4
	STR R3, [R1], #4

	ADD R2, R2, #1
	STR R3, [R1], #4
	STR R2, [R1], #4 //Guardar segundo termino de serie

	//Guardar M, DIR, y el valor anterior en stack inicialmente
	//M
	//DIR
	//0000
	//0000
	SUB SP, SP, #16
	SUB R0, R0, #2
	STR R3, [SP]
	STR R3, [SP, #4]
	STR R1, [SP, #8]
	STR R0, [SP, #12]
	
	MOV PC, LR
Final:
	B Final
	
	.data
SORTEDVALUES: .ds.l MAXN
FIBO: .ds.l M //Guardar memoria para la serie con FIMAX (90) términos
M: .dc.l 10 //CAidad de terminos solicitdos (entre 5 y 30)
POS: .dc.l  50, 15, 40, 39, 6, 33, 12, 23, 20, 6
ORDER: .dc.l 1
