.global _start
_start:
	.equ MAXN, 50 //Maximo de terminos solicitados
	.equ FIMAX, 90 //Cantidad de terminos a generar	
MOV R0, #FIMAX
MOV SP, #0 //Es totalmente importante inicializar en 0 el SP

LDR R1, =FIBO

BL Fibo
LDR R0, =N //L
LDR R0, [R0]
LDR R1, =SORTEDVALUES//Direcccion
LDR R2, =ORDER//Orden
LDR R2, [R2]
BL Sort

B Final
Fibo:
	SUB SP, SP, #4 //Guardar en stack
	STR LR, [SP]
	//Inicializar serie
	//Primer termino
	MOV R2, #0
	MOV R3, #0
	STR R2, [R1], #4
	STR R3, [R1], #4
	//Segundo termino
	ADD R2, R2, #1
	STR R3, [R1], #4
	STR R2, [R1], #4 //Guardar segundo termino de serie
	//Resto terminos de la serie
	SUB R0, R0, #2
	
	B LoopFibo
	
	MOV PC, LR
	
LoopFibo:
	CMP R0, #0
	BEQ	Out_Fibo //Si M = 0 termina de generar la serie
	SUB SP, SP, #8
	STR R0, [SP,#4]//M en stack
	STR R1, [SP]//DIR en stack
	//LR
	//M
	//DIR	
	LDR R0, [R1, #-12] //Extraer posicion anterior
	LDR R1, [R1, #-16]

	BL ADD64
	
	MOV R3, R1
	MOV R2, R0
	
	LDR R1, [SP]
	LDR R0, [SP, #4]
	ADD SP, SP, #8
	
	STR R3, [R1], #4
	STR R2, [R1], #4
	
	SUB R0,R0, #1
	
	B LoopFibo
	
ADD64:
	ADDS R0, R0, R2
	ADDCS R1, R1, #1 //CS/HS identifica carry de salida
	ADD R1, R1, R3
	MOV PC, LR
Out_Fibo:
	LDR LR, [SP]
	ADD SP, SP, #4
	MOV PC, LR //Sale de funcion Fibo
Sort:
	//R0 => L    R1= Dir    R2 => Order R3 => i
	MOV R3,#0 //Inicializar i
	//SUB R4, R0, #1 //Limite externo
	B LoopExterno
LoopExterno:
	CMP R3, R0 //
	BGE EndLoopOrdenar //Si (i) R3 > N
	PUSH{R3,R0}//Guardar i,L en stack
	
	SUB R0, R0, R3 //limite anidado
	SUB R0, R0, #1 //N- 1 - i
	
	MOV R3, #0 //Inicializar j	
	B LoopAnidado
	
LoopAnidado:	
	CMP R3, R0
	BGE EndLoopAnidado
	
	//Extraer de la memoria actual y siguiente (V[J] V[J+1]
	LSL R0, R3, #2 //j*4
	LDR R0, [R1, R0] //V[j] Actual
	ADD R3, R3, #1 //j=j+1
	LSL R12, R3, #2//(j+1)*4
	LDR R12, [R0, R12]  //V[j+1] Siguiente

	CMP R2, #0 //Order 
	BNE Else_Descendente //Si es ORD = 1 se va al else
	CMP R0, R12 //Comparar actual y siguiente
	BLT LoopAnidado
	
	//If Ascendente, ORDER = 0 => Intercambio
	STR R5, [R0, R9] //v[j+1] = temp (anterior)
	SUB R9, R9, #4
	STR R6, [R0, R9]
		
	B LoopAnidado
Else_Descendente:
	CMP R5, R6
	BGE LoopAnidado
	STR R5, [R0, R9] //v[j+1] = temp (anterior)
	SUB R9, R9, #4
	STR R6, [R0, R9]
	B LoopAnidado
EndLoopAnidado:
	ADD R2, R2, #1
	B LoopOrdenar
EndLoopOrdenar:
	MOV PC, LR

Final:
	B Final
	
	.data
SORTEDVALUES: .ds.l MAXN*2
FIBO: .ds.l FIMAX*2 //Guardar memoria para la serie con FIMAX (90) términos
N: .dc.l 10 //CAidad de terminos solicitdos (entre 10 Y 50)
POS: .dc.l  50, 15, 40, 39, 6, 33, 12, 23, 20, 6
ORDER: .dc.l 1
