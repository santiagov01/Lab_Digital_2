module deco7seg_hexa(
input logic [4:0] entrada,
output logic [6:0] SEG,
output logic [6:0] SEG1
);
    logic [3:0] unidades;
    logic [3:0] decenas;

always_comb begin

    unidades = entrada%4'b1010;
    decenas = entrada/4'b1010;
	 
    case(unidades)            //abcdefg
        4'b0000: SEG = 7'b1000000; // 0
        4'b0001: SEG = 7'b1111001; // 1
        4'b0010: SEG = 7'b0100100; // 2
        4'b0011: SEG = 7'b0110000; // 3
        4'b0100: SEG = 7'b0011001; // 4
        4'b0101: SEG = 7'b0010010; // 5
        4'b0110: SEG = 7'b0000010; // 6
        4'b0111: SEG = 7'b1111000; // 7
        4'b1000: SEG = 7'b0000000; // 8
        4'b1001: SEG = 7'b0011000; // 9

        default: SEG = 7'b1111111;

        endcase
    case(decenas)             //abcdefg
        4'b0000: SEG1 = 7'b1000000; // 0
        4'b0001: SEG1 = 7'b1111001; // 1
        4'b0010: SEG1 = 7'b0100100; // 2
        4'b0011: SEG1 = 7'b0110000; // 3
        4'b0100: SEG1 = 7'b0011001; // 4
        4'b0101: SEG1 = 7'b0010010; // 5
        4'b0110: SEG1 = 7'b0000010; // 6
        4'b0111: SEG1 = 7'b1111000; // 7
        4'b1000: SEG1 = 7'b0000000; // 8
        4'b1001: SEG1 = 7'b0011000; // 9

        default: SEG1 = 7'b1111111;
        endcase

end
endmodule
