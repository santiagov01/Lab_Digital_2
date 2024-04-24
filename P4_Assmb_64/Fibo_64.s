.global _start
_start:
	.equ MAXN, 50 //Maximo de terminos solicitados
	.equ FIMAX, 90 //Cantidad de terminos a generar
	
LDR R2, =ORDER//Orden
LDR R2, [R2]

LDR R0, =N //L
LDR R0, [R0]

LDR R1, =SORTEDVALUES
BL Range_rev //Revisar Rango de orden y terminos solicitados
MOV R2, #0 //Contador para revisar valores de posiciones solicitadas
LDR R3, =POS
BL Loop_rev //Revisar lista

MOV R0, #FIMAX
MOV SP, #0 //Es totalmente importante inicializar en 0 el SP
LDR R1, =FIBO

BL Fibo

LDR R0, =N //L
LDR R0, [R0]
LDR R1, =POS//Direcccion
LDR R2, =ORDER//Orden
LDR R2, [R2]
BL Sort

BL ExtraerFinal
B Final
Range_rev:
	CMP R0, #10 
	BLT Abort //N < 5?
	CMP R0, #50
	BGT Abort //N > 50
	CMP R2, #1 //Orden
	BGT Abort
	CMP R2, #0
	BLT Abort
	MOV PC, LR //En caso de que todo este bien, continue
Loop_rev:
	CMP R2, R0
	BGE EndLoop_rev
	LDR R12, [R3], #4 //Cargar de vector POS
	CMP R12, #1
	BLO Abort
	CMP R12, #90
	BGT Abort
	ADD R2,R2, #1
	B Loop_rev
	
EndLoop_rev:
	MOV PC, LR
Abort:
	LDR R0, =0xA5A5A5A5
	STR R0, [R1]
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
	MOV R12,#0
	//SUB R4, R0, #1 //Limite externo
	B LoopExterno
LoopExterno:
	CMP R3, R0 //
	BGE EndLoopOrdenar //Si (i) R3 > N
	PUSH {R3}//Guardar i,L en stack
	PUSH {R0}
	
	SUB R0, R0, R3 //limite anidado
	SUB R0, R0, #1 //N- 1 - i

	//i
	//L
	//lim_anidado
	MOV R3, #0 //Inicializar j	
	B LoopAnidado
	
LoopAnidado:	
	CMP R3, R0
	
	BGE EndLoopAnidado
	PUSH {R0} //llevar limite anidado a stack
	//Extraer de la memoria actual y siguiente (V[J] V[J+1]
	LSL R0, R3, #2 //j*4
	LDR R0, [R1, R0] //V[j] Actual
	ADD R3, R3, #1 //j=j+1
	LSL R12, R3, #2//(j+1)*4
	LDR R12, [R1, R12]  //V[j+1] Siguiente

	CMP R2, #0 //Order 
	BNE Else_Descendente //Si es ORD = 1 se va al else
	CMP R0, R12 //Comparar actual y siguiente
	BLT AfterCompare
	PUSH {R2} //Guardo en stack para usar registro
	//If Ascendente, ORDER = 0 => Intercambio
	LSL R2, R3, #2 //(j+1)*4
	STR R0, [R1, R2] //v[j+1] = actual
	SUB R2, R2, #4 //(j)*4
	STR R12, [R1, R2] //v[j] = siguiente
	POP {R2}	
	B AfterCompare
Else_Descendente:
	CMP R0, R12
	BGE AfterCompare
	PUSH {R2} //Guardo en stack para usar registro
	LSL R2, R3, #2 //(j+1)*4
	STR R0, [R1, R2] //v[j+1] = actual
	SUB R2, R2, #4 //(j)*4
	STR R12, [R1, R2] //v[j] = siguiente
	POP {R2}	
	B AfterCompare
AfterCompare:
	POP {R0} //Devolver el limite anidado.
	B LoopAnidado
EndLoopAnidado:
	POP {R0}//Sacar i,L en stack
	POP {R3}
	ADD R3, R3, #1
	B LoopExterno
EndLoopOrdenar:
	MOV PC, LR
ExtraerFinal:
	//R0 => Direccion POS
	//R1, =FIBO
	// R2, =SORTEDVALUES
	//MOV R3, #0 //Valor de la posicion
	//MOV R4, #0 //Valor de la serie

	
	//R0 = N. sigue igual
	MOV R7, R0 //R7 = N
	LDR R0, =POS
	LDR R1, =FIBO
	LDR R2, =SORTEDVALUES
	MOV R3, #0 //contador
	MOV R12, #0 //index
LoopExtraer:

	CMP R3, R7
	
	BGE Final
	LDR R12, [R0], #4 //index. Extraer la posicion de POS
	SUB R12, R12, #1 //Para extraer la posicion verdadera (index-1)
	LSL R12, R12, #3 //r3 = (r3*4)*2 porque son de 64 bits
	
	PUSH {R0} //Necesito otro registro
	LDR R0, [R1, R12]//Cargar primera mitad del valor de serie. Me desplazo R12 posiciones	
	STR R0, [R2], #4 //Lo almaceno en memoria
	ADD R12, R12, #4 //Cargar la otra mitad
	LDR R0, [R1, R12]
	STR R0, [R2], #4
	POP {R0}
	
	
	ADD R3, R3, #1
	B LoopExtraer
Final:
	B Final
	
	.data
SORTEDVALUES: .ds.l MAXN*2
FIBO: .ds.l FIMAX*2 //Guardar memoria para la serie con FIMAX (90) términos
N: .dc.l 10 //CAidad de terminos solicitdos (entre 10 Y 50)
POS: .dc.l  9, 15, 40, 39, 6, 33, 12, 23, 20, 6
ORDER: .dc.l 0  
