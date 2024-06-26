.global _start
_start:
	
	.equ MAXN, 30 //Maximo de terminos solicitados
	.equ FIMAX, 40 //Cantidad de terminos a generar

LDR R0, =FIBO //Direccion de memoria donde se guarda la serie
MOV R1, #FIMAX //40
LDR R10, =ORDER
LDR R10, [R10]

LDR R7, =N //Cargo dirrecion de N
LDR R7, [R7] //Cargar en R7 lo que hay en la dirrecion N

LDR R5, =SORTEDVALUES
MOV R2, #0 //Contador para revisar valores de posiciones solicitadas

BL Range_rev //Revisar Rango
LDR R3, =POS
BL Loop_rev //Revisar lista

BL Fibo
//En estos momentos no necesito usar R0,R1,R2,R3,R4

LDR R0, =POS
MOV R2, #0 //Contador i, for externo
MOV R8, R7
SUB R7, R7, #1 //N-1
BL LoopOrdenar

//cambiar***
LDR R7, =N //Cargo dirrecion de N
LDR R7, [R7] //Cargar en R7 lo que hay en la dirrecion N
LDR R1, =FIBO //Dirección de la serie fibonacci
LDR R2, =SORTEDVALUES //Direccion valores ordenados
MOV R3, #0 //Valor de la posicion
MOV R4, #0 //Valor de la serie
MOV R5, #0 //Contador
BL ExtraerFinal
BL Final
Range_rev:
	CMP R7, #5 
	BLT Abort //N < 5?
	CMP R7, #30
	BGT Abort //N > 30
	CMP R10, #1
	BGT Abort
	CMP R10, #0
	BLT Abort
	MOV PC, LR //En caso de que todo este bien, continue
Loop_rev:
	CMP R2, R7
	BGE EndLoop_rev
	LDR R4, [R3], #4
	CMP R4, #1
	BLO Abort
	CMP R4, #40
	BGT Abort
	ADD R2,R2, #1
	B Loop_rev
	
EndLoop_rev:
	MOV PC, LR
Abort:
	LDR R1, =0xA5A5A5A5
	STR R1, [R5]
	B Final
Final:
	B Final

//R2 => Anterior
//R3 => Actual
Fibo:
    MOV R2, #0         // Valor inicial de Fibonacci
    MOV R3, #1         // Segundo valor de Fibonacci
    STR R2, [R0], #4   // Almacenamos el primer valor de Fibonacci en [R0]
	//R0 = R0 + 4. Se actualiza después
    STR R3, [R0], #4   // Almacenamos el segundo valor de Fibonacci
    SUB R1, R1, #2     // Decrementamos N por 2 (ya que ya hemos calculado los dos primeros valores)

Loop:
    CMP R1, #0         // Comparamos si N es igual a cero
    BEQ EndLoop        // Si es cero, salimos del bucle

    ADD R4, R2, R3     // Calculamos el siguiente valor de Fibonacci sumando los dos últimos
	//CMP R4, R0         // Comparamos si R4 es igual a R0
	STR R4, [R0], #4   // Almacenamos el nuevo valor de Fibonacci
    //BEQ EndLoop        // Si es cero, salimos del bucle
	
    MOV R2, R3         // Actualizamos el primer valor de Fibonacci con el segundo
    MOV R3, R4         // Actualizamos el segundo valor de Fibonacci con el nuevo valor
    SUBS R1, R1, #1    // Decrementamos N
    B Loop             // Volvemos al inicio del bucle

EndLoop:
    MOV PC, LR

LoopOrdenar:
	//R2 => i, R3 => j R7=> N
	
	
	CMP R2, R7
	BGE EndLoopOrdenar //Si (i) R2  > N
	LDR R8, =N //Cargo dirrecion de N
	LDR R8, [R8]
	MOV R3, #0
	
	SUB R8, R8, #1
	SUB R8, R8, R2 //N-1 - i

	B LoopAnidado
	
LoopAnidado:	
	CMP R3, R8
	BGE EndLoopAnidado	
	//Extraer de la memoria actual y siguiente (V[J] V[J+1]
	LSL R9, R3, #2
	LDR R5, [R0, R9] //V[j]
	ADD R9, R9, #4
	LDR R6, [R0, R9]  //V[j+1]
	
	ADD R3, R3, #1 //j = j+1
	CMP R10, #0
	BNE Else_Descendente //Si es ORD = 1 se va al else
	CMP R5, R6
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

ExtraerFinal:
	//R0 => Direccion POS
	//LDR R1, =FIBO
	//LDR R2, =SORTEDVALUES
	//MOV R3, #0 //Valor de la posicion
	//MOV R4, #0 //Valor de la serie
	//R7 => N
	CMP R5, R7
	
	BGE Final
	LDR R3, [R0], #4 //Extraer la posicion del arreglo
	SUB R3, R3, #1 //Para extraer la posicion verdadera (index-1)
	LSL R3, R3, #2 //r3 = r3*4
	LDR R4, [R1, R3]//Cargar el valor de la serie. Me desplazo R3 posiciones
	
	STR R4, [R2], #4 //Lo almaceno en memoria
		
	ADD R5, R5, #1
	B ExtraerFinal

	
	.data
SORTEDVALUES: .ds.l MAXN
FIBO: .ds.l FIMAX //Guardar memoria para la serie con FIMAX (40) términos
N: .dc.l 10 //CAidad de terminos solicitdos (entre 5 y 30)
POS: .dc.l  50, 15, 40, 39, 6, 33, 12, 23, 20, 6
ORDER: .dc.l -2
