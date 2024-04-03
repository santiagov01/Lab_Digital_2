// Example No. 4
.global _start
.text
_start:
ldr r0, =Value1
ldr r1, [r0], #4
ldr r2, [r0]
bl Suma
bl Guardar
bl Resta
bl Guardar
stop:
b stop
Suma:
add r0, r1, r2
mov pc, lr
Resta:
sub r0, r1, r2
mov pc, lr
Guardar:
ldr r3, =Result
str r0, [r3]
mov pc, lr
.data
Value1: .dc.l 9
Value2: .dc.l 5
Result: .ds.l 4
