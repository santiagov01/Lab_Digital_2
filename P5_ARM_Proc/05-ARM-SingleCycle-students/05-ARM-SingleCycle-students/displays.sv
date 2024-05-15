module displays(
					  input logic  [7:0] num,
					  input logic  [3:0] letter,
					  output logic [6:0] disp4, disp3, disp2, disp1, disp0);		
	
	logic signeLight; 
	logic [7:0] aux_num; 
	logic [3:0] signo,auxletter, Decenas, Centenas, Unidades; 	
		/*
	always_comb begin 
		
		if(signeLight == 1'b1)signeLigth
			
	end */
	
	
	always_comb begin
    if (num[7] == 1'b1) begin //Si es negativo
        signo = 4'b1011; 
		signeLight = 1'b1;
		aux_num = (~num + 1); //Convierte a positivo
		      
	  end else begin			
		signo = 4'b1111;
		signeLight = 1'b0; 
		aux_num = num;
	  
	  end  
	end
	
	assign auxletter = letter; 
	assign Centenas = (aux_num/100); 
	assign Decenas = ((aux_num % 100)/10);
	assign Unidades = ((aux_num % 100)%10); 
	/*
	always_comb begin 
		
		if(signeLight == 1'b1)signeLigth
			
	end */
	
	peripheral_deco7seg dp4 (auxletter, 1, disp4); //Letra
	peripheral_deco7seg dp3 (signo, 0, disp3); //Signo
	//Numeros
	peripheral_deco7seg dp2 (Centenas, 0, disp2);
	peripheral_deco7seg dp1 (Decenas, 0, disp1);
	peripheral_deco7seg dp0 (Unidades, 0, disp0);
					

					
endmodule 