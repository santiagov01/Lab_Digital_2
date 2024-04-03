// Example No. 2
.global _start
.equ N, 5
.text
_start:
	mov r0,#0
	mov r1,#0
	ldr r2,=dataIn //Pasar direccion de dataIn a r2
loop:
	cmp r0, #(N-1)
	bhi endloop //¿r0 > 4? NO, continua.
	ldr r3, [r2] // Carga datos de direccion de memoria guardada en r2 en r3
	add r1, r1, r3
	add r2, r2, #4
	add r0, r0, #1
	b loop //saltar a loop
endloop:
	ldr r2,=dataOut //pasar direccion de memoria =dataOut a r2
	str r1, [r2] //pasar valor de r1 a r2 (dataOut)
stop:
	b stop
.data
dataIn: .dc.l 1,2,3,-4,5,9
dataOut: .ds.l 1
