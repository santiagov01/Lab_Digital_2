module counter(
	input logic RST, // reset
	input logic EN, // enable
	input logic CLK, // clock
	input logic [3:0] D, // data
	input logic [1:0] S, // function selector
	output logic [3:0] Q); // output
	logic [3:0] rCounter; // internal counter signal

always_ff @(posedge CLK, posedge RST) begin
	if (RST)
		rCounter <= 1'b0; // reset
	else if (EN) begin
			case (S)
				2'b01: rCounter <= D; // data load
				2'b10: rCounter <= rCounter + 1'b1; // count up
				2'b11: rCounter <= rCounter - 1'b1; // count down
			endcase
		end
	end
	
	assign Q = rCounter; // assign the internal counter signal to the output Q
endmodule