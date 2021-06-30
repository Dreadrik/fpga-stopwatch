`default_nettype none

module stopwatch	
	#( 
		// Multipliex segments frequency 1kHz (100MHz / 100k)
		parameter SEL_CE_DIV = 100_000,		
		// Increment counter eveery 1/10'th of a second (100MHz / 10M)
		parameter INC_CE_DIV = 10_000_000,	
		// Clock segment data every 8 bits of SYSCLK gives (100MHz / 267 ~= 390kHz)
		parameter SEG_CLK_BITS = 8,
		// Debounce time for button (100MHz / 500k = 200Hz = 5ms)
		parameter DBNC_DIV = 500_000
	)
	(
		input wire SYSCLK, BTN,
		output wire SEGA, SEGB, SEGC, SEGD, SEGE, SEGF, SEGG, SEGDP,
		output wire SEGCLK,
		output wire [4:0] SEGCAT
	);

	// Button handler
	wire clear, prepare_start, running;
	button_handler 
		#(
			.DBNC_DIV(DBNC_DIV)
		) 
		bh0(
			.clk(SYSCLK), 
			.button(~BTN), 
			.clear(clear),
			.prepare_start(prepare_start),
			.running(running)
		);

	// Clock enable generator for digit increments
	wire inc_ce;
	clock_enable 
		#(
			.DIV(INC_CE_DIV)
		) 
		ce0(
			.clk(SYSCLK), 
			.reset(prepare_start), 
			.clk_enable(inc_ce)
		);

	// 5 BCD digits
	wire inc = (running & inc_ce);

	wire [5 * 4 - 1:0] digits;
	bcd_counter 
		bcd_counter0(
			.clk(SYSCLK), 
			.reset(clear), 
			.inc(inc), 
			.digits(digits)
		);

	// Disable the tens digit of the minutes value, if it is zero.
	wire minute_tens_enable = (digits[19:16] != 0);
	// Disable the tens digit of the seconds value, if it is zero.
	wire second_tens_enable = (digits[11:8] != 0);

	// Display logic
	display 
		#(
			.USE_HEX(0),
			.DIGITS(5), 
			.SEL_CE_DIV(SEL_CE_DIV), 
			.SEG_CLK_BITS(SEG_CLK_BITS)
		) 
		display0(
			.clk(SYSCLK), 
			.digits(digits),
			.digit_enable({ minute_tens_enable, 1'b1, second_tens_enable, 2'b11 }),
			.dp_enable(5'b01010), // Activate decimal point segments for digit 2 and 4
			.seg_clk(SEGCLK), 
			.segments({ SEGA, SEGB, SEGC, SEGD, SEGE, SEGF, SEGG, SEGDP }), 
			.cathodes(SEGCAT)
		);

endmodule
