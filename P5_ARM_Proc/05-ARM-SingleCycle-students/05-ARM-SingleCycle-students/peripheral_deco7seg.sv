// ************************
// 7-segment Decoder Module
// ************************
module peripheral_deco7seg(
	input  logic [3:0] D,
	input  logic EXTENDED,
	output logic [6:0] SEG
);
 
	always_comb begin
		if (EXTENDED == 0) begin
			case(D)				 //gfedcba
				4'b0000: SEG = 7'b1000000; // 0x40  -0
				4'b0001: SEG = 7'b1111001; // 0x79	-1
				4'b0010: SEG = 7'b0100100; // 0x24	-2
				4'b0011: SEG = 7'b0110000; // 0x30	-3
				4'b0100: SEG = 7'b0011001; // 0x19	-4
				4'b0101: SEG = 7'b0010010; // 0x12 	-5
				4'b0110: SEG = 7'b0000010; // 0x02	-6
				4'b0111: SEG = 7'b1111000; // 0x78	-7
				4'b1000: SEG = 7'b0000000; // 0x00	-8
				4'b1001: SEG = 7'b0011000; // 0x18	-9
				4'b1011: SEG = 7'b0111111; // signo --
				default: SEG = 7'b1111111; // por defecto - xxx
			endcase
		end else begin		
			case(D)				 //gfedcba
				4'b0000: SEG = 7'b0001000; // 0x08 (A)
 				4'b0001: SEG = 7'b0000011; // 0x03 (b)
				4'b0010: SEG = 7'b1001110; // 0x46 (r)
				default: SEG = 7'b1111111;
			endcase	
		end
	end
endmodule
