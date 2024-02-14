module cntdiv_n #(TOPVALUE = 16) (clk, rst, clkout);
	input logic clk, rst;
	output logic clkout;
	
	localparam BITS = $clog2(TOPVALUE/2);
	logic [BITS-1:0] rCounter;
	
	//proceso secuencial
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			rCounter <= 0; //Inicializa
			clkout <= 0;
		end else begin
			rCounter <= rCounter+ 1'b1; //tener en cuenta retraso
			if(rCounter == TOPVALUE/2 - 1)begin //rCounter aun no se actualiza
				rCounter <= 0;
				clkout <= ~clkout; //Invierte
			end
		end
		
	
	end
	
endmodule