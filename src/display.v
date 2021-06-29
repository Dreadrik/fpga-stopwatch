// display holds 5 digits.
// It creates 5 single counts and wire them together so that when one overflows, the next is incremented.

`default_nettype none

module display(
	input wire clk, reset, inc, 
	output wire [5*4-1:0] digits);

	wire c0, c1, c2, c3;
	// Tens
	bcd_digit #(.ROLLOVER(9)) digit0(.clk(clk), .reset(reset), .inc(inc), 	.digit(digits[ 3: 0]), .carryout(c0));

	// Seconds
	bcd_digit #(.ROLLOVER(9)) digit1(.clk(clk), .reset(reset), .inc(c0), 	.digit(digits[ 7: 4]), .carryout(c1));
	bcd_digit #(.ROLLOVER(5)) digit2(.clk(clk), .reset(reset), .inc(c1), 	.digit(digits[11: 8]), .carryout(c2));

	// Minutes
	bcd_digit #(.ROLLOVER(9)) digit3(.clk(clk), .reset(reset), .inc(c2), 	.digit(digits[15:12]), .carryout(c3));
	/* verilator lint_off PINMISSING */
	bcd_digit #(.ROLLOVER(5)) digit4(.clk(clk), .reset(reset), .inc(c3), 	.digit(digits[19:16]));
	/* verilator lint_on PINMISSING */
endmodule