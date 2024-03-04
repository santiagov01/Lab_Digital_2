//Codigo para decodificar la salida de bits y pasarlos a unidades y decenas
//Se añadira al modulo principal
module main (cnt_secLeft, unidades, decenas)
input logic[] cnt_secLeft;
output logic[7:0] unidades,decenas;

unidades = entrada%4'b1010;
decenas = entrada/4'b1010;

logic [7:0] tUNI;
logic [7:0] tDEC;
deco_7seg deco_uni(unidades,tUNI);
deco_7seg deco_dec(decenas,tDEC);
end module;