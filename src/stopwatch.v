`default_nettype none

module stopwatch	
	#( 
		parameter SEL_CE_DIV = 100_000,
		parameter INC_CE_DIV = 10_000_000,
		parameter SEG_CLK_BITS = 8,
		parameter DBNC_DIV = 500_000
	)
	(
		input wire SYSCLK, BTN,
		output wire SEGA, SEGB, SEGC, SEGD, SEGE, SEGF, SEGG, SEGDP,
		output wire SEGCLK,
		output wire [4:0] SEGCAT
	);

	// Button debounce
	wire btn_tap;
	debounce #(.DIV(DBNC_DIV)) dbnc(.clk(SYSCLK), .button(~BTN), .out(btn_tap));

	// State machine
	localparam 
		resetted 	= 3'd0,
		starting 	= 3'd1,
		started 	= 3'd2,
		stopping 	= 3'd3,
		stopped 	= 3'd4,
		resetting 	= 3'd5;

	reg [2:0] 
		state = resetted,
		next_state = resetted;

	always @(state, btn_tap) begin
		case (state)
			resetted: next_state = btn_tap ? starting : resetted;
			starting: next_state = btn_tap ? starting : started;
			started: next_state = btn_tap ? stopping : started;
			stopping: next_state = btn_tap ? stopping : stopped;
			stopped: next_state = btn_tap ? resetting :  stopped;
			resetting: next_state = btn_tap ? resetting : resetted;
			default: next_state = resetted;
		endcase
	end

	always @(posedge SYSCLK) begin
		state = next_state;
	end

	wire digit_reset = (state == resetting);
	wire inc_ce_reset = (state == starting);
	wire inc = ((state == started) && inc_ce);

	// Clock enable generator for digit increments
	wire inc_ce;
	clock_enable #(.DIV(INC_CE_DIV)) ce1(.clk(SYSCLK), .reset(inc_ce_reset), .clk_enable(inc_ce));

	// 5 BCD digits
	wire [5 * 4 - 1:0] digits;
	display display0(.clk(SYSCLK), .reset(digit_reset), .inc(inc), .digits(digits));

	// Clock enable for digit selection multiplexer
	wire sel_ce;
	clock_enable #(.DIV(SEL_CE_DIV)) ce0(.clk(SYSCLK), .reset(1'b0), .clk_enable(sel_ce));

	// Digit selection counter
	reg [2:0] sel = 3'd0;
	wire sel_rollover = (sel == 3'd4);
	always @(posedge SYSCLK) begin
		if (sel_ce) 
			sel <= (sel_rollover) ? 3'd0 : sel + 3'd1;
	end

	// Digit selection
	wire [3:0] digit;
	assign digit = digitSel(sel, digits);

	// 7-segment decoder
	wire [7:0] segments;
	assign segments = bcdTo7Seg(digit);

	wire dp = (sel == 3'd1 || sel == 3'd3);
	assign { SEGA, SEGB, SEGC, SEGD, SEGE, SEGF, SEGG, SEGDP } = { segments[7:1], dp };

	// Active cathode selection
	assign SEGCAT[0] = (sel == 3'd0);
	assign SEGCAT[1] = (sel == 3'd1);
	assign SEGCAT[2] = (sel == 3'd2);
	assign SEGCAT[3] = (sel == 3'd3);
	assign SEGCAT[4] = (sel == 3'd4);

	// Segment update clock
	reg [SEG_CLK_BITS - 1:0] segclk = 0;
	always @(posedge SYSCLK) begin
		segclk <= segclk + 1;
	end
	assign SEGCLK = segclk[SEG_CLK_BITS - 1];	// Divide 100 Mhz clock by 256 gives ~290kHz

	//// Functions

	// Digit selector
	function [3:0] digitSel(input [2:0] sel, input [5*4-1:0] digits);
		case (sel)
		    3'd0: digitSel = digits[ 3: 0];
		    3'd1: digitSel = digits[ 7: 4];
		    3'd2: digitSel = digits[11: 8];
		    3'd3: digitSel = digits[15:12];
		    3'd4: digitSel = digits[19:16];
		    default: digitSel = 4'bx;
		endcase
	endfunction

	// 7-segments decoder
	function [7:0] bcdTo7Seg(input [3:0] digit);
		case (digit)
		    4'h0: bcdTo7Seg = 8'b11111100;
		    4'h1: bcdTo7Seg = 8'b01100000;
		    4'h2: bcdTo7Seg = 8'b11011010;
		    4'h3: bcdTo7Seg = 8'b11110010;
		    4'h4: bcdTo7Seg = 8'b01100110;
		    4'h5: bcdTo7Seg = 8'b10110110;
		    4'h6: bcdTo7Seg = 8'b10111110;
		    4'h7: bcdTo7Seg = 8'b11100000;
		    4'h8: bcdTo7Seg = 8'b11111110;
		    4'h9: bcdTo7Seg = 8'b11110110;
		    default: bcdTo7Seg = 8'bx;
		endcase
	endfunction
endmodule
