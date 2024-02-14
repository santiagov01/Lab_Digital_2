module main #(SHIFT_BITS = 10, TOPVALUE = 50_000_000) (clk, rst, qLeds);
	input logic clk, rst;
	output logic [SHIFT_BITS -1:0] qLeds;
	
	//Internal signals
	logic clkout;
	//botones en tarjeta estan activos en bajo, hacer conversion
	
	cntdiv_n #(TOPVALUE) cntDiv (clk, ~rst, clkout);  //Se puede instanciar otros modulos
	//cntDiv: Es el nombre de la intstancia (como objetos en C++)
	
	shift_led #(SHIFT_BITS) shifter (clkout, ~rst, qLeds);
endmodule