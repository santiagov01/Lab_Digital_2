module shift_led #(BITS = 10) (clk, rst, qLeds);
	input logic clk, rst;
	output logic [BITS -1 : 0] qLeds;
	
	logic toLeft;
	
	always @(posedge clk, posedge rst) begin
		if (rst) begin 
			qLeds <= 1'b1; //Bit menos significativo encendido. 0001
			toLeft <= 1'b1;
		end else if (toLeft) begin
			qLeds <= qLeds << 1; //Desplazar 1 a la izquierda 0001=>0010
			if (qLeds [BITS -2]) //0100 (recordar que no se ha actualizado)
				toLeft <= 0;//Cambia direccion
			end else begin
			qLeds <= qLeds >> 1;
			if(qLeds[1])
			toLeft <= 1;
		end
	end
endmodule