module displays_tb()
logic  [7:0] num;
logic  [3:0] letter;
logic [6:0] disp4, disp3, disp2, disp1, disp0;	
    // initialize test
	initial
	begin
		reset <= 0; #DELAY; 
		reset <= 1; 
		
		switches <= 10'd4; #(DELAY*2000);
		
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule   	// initialize test
	initial
	begin
		reset <= 0; #DELAY; 
		reset <= 1; 
		
		switches <= 10'd4; #(DELAY*2000);
		
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end