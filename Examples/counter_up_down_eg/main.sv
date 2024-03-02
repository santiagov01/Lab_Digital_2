module main #(FPGAFREQ = 50_000_000) (
input logic CLK,
input logic RST,
input logic EN,
input logic [1:0] S,
input logic [3:0] D,
output logic [7:0] SEG);
// Internal signals
logic internalClk;
logic [3:0] Q;
logic [7:0] tSEG; // To invert the signals
// Components connection
cntdiv_n #(FPGAFREQ) cntDiv (CLK, ~RST, internalClk);
counter counter0 (~RST, EN, internalClk, D, S, Q);
deco7seg_hexa deco0 (Q, tSEG);
assign SEG = ~tSEG;
endmodule

module tb_main();
// local parameters
localparam CLK_PERIOD = 20ns;
localparam FPGAFREQ = 4; // 4hz
// internal signals
logic CLK;
logic RST;
logic EN;
logic [1:0] S;
logic [3:0] D;
logic [7:0] SEG;
// circuit instance
main #(FPGAFREQ) main_u0 (CLK, ~RST, EN, S, D, SEG);
// Simulation process
initial begin
CLK = 0;
RST = 1;
EN = 1;
S = 2'b10;
D = 4'b0000;
#(CLK_PERIOD * FPGAFREQ);
RST = 0;
#(CLK_PERIOD * 20 * FPGAFREQ);
S = 2'b11;
#(CLK_PERIOD * 20 * FPGAFREQ);
$stop;
end
always #(CLK_PERIOD / 2) CLK = ~CLK;
endmodule
