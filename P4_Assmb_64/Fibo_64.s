.global _start
_start:
	.equ MAXN, 50 //Maximo de terminos solicitados
	.equ M, 5 //Cantidad de terminos a generar
MOV R0, #M
LDR R1, =FIBO

BL Fibo
BL Sort

B Final
Fibo:
	SUB SP, SP, #4
	STR LR, [SP]
	MOV R2, #0
	MOV R3, #0
	STR R2, [R1], #4
	STR R3, [R1], #4

	ADD R2, R2, #1
	STR R3, [R1], #4
	STR R2, [R1], #4 //Guardar segundo termino de serie
	SUB R0, R0, #2
	//LR
	//Guardar M, DIR, y el valor anterior en stack inicialmente
	//M
	//DIR
	//0000
	//0000
	
	/*
	SUB SP, SP, #20
	SUB R0, R0, #2
	STR LR, [SP] //Guardar dirección para que luego regrese
	STR R3, [SP,#4] //Guardar en stack 0
	STR R3, [SP, #8]//Guardar en stack 0
	//Como voy a modificar R0 y R1, stack
	STR R1, [SP, #12]//Guardo dirreccion en stack
	STR R0, [SP, #16]//Guardo M en stack
	*/
	
	B LoopFibo
	
	MOV PC, LR
	
LoopFibo:
	CMP R0, #0
	BEQ	Out_Fibo //Si M = 0 termina de generar la serie
	
	BL ADD64
	SUB R0,R0, #1
	B LoopFibo
	
ADD64:
	MOV PC, LR
Out_Fibo:
	LDR LR, [SP]
	ADD SP, SP, #4
	MOV PC, LR //Sale de funcion Fibo
Sort:
	MOV PC, LR
Final:
	B Final
	
	.data
SORTEDVALUES: .ds.l MAXN
FIBO: .ds.l M //Guardar memoria para la serie con FIMAX (90) términos
M: .dc.l 10 //CAidad de terminos solicitdos (entre 5 y 30)
POS: .dc.l  50, 15, 40, 39, 6, 33, 12, 23, 20, 6
ORDER: .dc.l 1
