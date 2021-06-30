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
	clock_enable #(.DIV(INC_CE_DIV)) ce0(.clk(SYSCLK), .reset(inc_ce_reset), .clk_enable(inc_ce));

	// 5 BCD digits
	wire [5 * 4 - 1:0] digits;
	bcd_counter bcd_counter0(.clk(SYSCLK), .reset(digit_reset), .inc(inc), .digits(digits));

	// Display logic
	wire [7:0] segments;
	display #(.SEL_CE_DIV(SEL_CE_DIV), .SEG_CLK_BITS(SEG_CLK_BITS)) display0(.clk(SYSCLK), .digits(digits), .seg_clk(SEGCLK), .segments(segments), .cathodes(SEGCAT));

	wire segdp = (SEGCAT[1] || SEGCAT[3]);
	assign { SEGA, SEGB, SEGC, SEGD, SEGE, SEGF, SEGG, SEGDP } = { segments[7:1], segdp };

endmodule
