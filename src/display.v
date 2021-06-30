// display drives DIGIT number of 7-segment LED displays.

`default_nettype none

module display
	#(
		// If 0: Use BCD, else use hexadecimal display
		parameter USE_HEX = 0,
		// Number of digits used
		parameter DIGITS = 5,
		// Division of clock frequency for digit multiplexing
		parameter SEL_CE_DIV = 100_000,
		// Number of bits used for the segment clock divider
		parameter SEG_CLK_BITS = 8
	)
	(
		input wire clk, 
		input wire [DIGITS * 4 - 1:0] digits,
		input wire [DIGITS - 1:0] digit_enable,
		input wire [DIGITS - 1:0] dp_enable,
		output wire seg_clk,
		output wire [7:0] segments,
		output wire [DIGITS - 1:0] cathodes
	);

	// Clock enable for digit selection multiplexer
	wire sel_ce;
	clock_enable #(.DIV(SEL_CE_DIV)) ce0(.clk(clk), .reset(1'b0), .clk_enable(sel_ce));

	// Digit selection counter
	localparam SEL_BITS = $clog2(DIGITS);
	reg [SEL_BITS - 1:0] sel = 0;
	wire sel_rollover = (sel == (DIGITS - 1));
	always @(posedge clk) begin
		if (sel_ce) 
			sel <= (sel_rollover) ? 0 : sel + 1;
	end

	// Digit selection
	wire [3:0] digit;
	wire dp;

	// Current digit, decimal point and cathode selection
	generate
		genvar i;
		for (i = 0; i < DIGITS; i = i + 1) begin
			wire currentsel = (sel == i);
			assign digit = currentsel ? digits[(i + 1) * 4 -1:i * 4] : 4'bzzzz;
			assign dp = currentsel ? dp_enable[i] : 1'bz;
			assign cathodes[i] = currentsel & digit_enable[i];
		end
	endgenerate

	// 7-segment decoder
	generate
		if (USE_HEX)
			assign segments = { hexTo7Seg(digit), dp };
		else
			assign segments = { bcdTo7Seg(digit), dp };
	endgenerate

	// Segment update clock
	reg [SEG_CLK_BITS - 1:0] segclk = 0;
	always @(posedge clk) begin
		segclk <= segclk + 1;
	end
	assign seg_clk = segclk[SEG_CLK_BITS - 1];

	//// Functions

	// 7-segments bcd decoder
	function [6:0] bcdTo7Seg(input [3:0] digit);
		case (digit)
		    4'h0: bcdTo7Seg = 7'b1111110;
		    4'h1: bcdTo7Seg = 7'b0110000;
		    4'h2: bcdTo7Seg = 7'b1101101;
		    4'h3: bcdTo7Seg = 7'b1111001;
		    4'h4: bcdTo7Seg = 7'b0110011;
		    4'h5: bcdTo7Seg = 7'b1011011;
		    4'h6: bcdTo7Seg = 7'b1011111;
		    4'h7: bcdTo7Seg = 7'b1110000;
		    4'h8: bcdTo7Seg = 7'b1111111;
		    4'h9: bcdTo7Seg = 7'b1111011;
		    default: bcdTo7Seg = 7'bx;
		endcase
	endfunction

	// 7-segments hex decoder
	function [6:0] hexTo7Seg(input [3:0] digit);
		case (digit)
		    4'h0: hexTo7Seg = 7'b1111110;
		    4'h1: hexTo7Seg = 7'b0110000;
		    4'h2: hexTo7Seg = 7'b1101101;
		    4'h3: hexTo7Seg = 7'b1111001;
		    4'h4: hexTo7Seg = 7'b0110011;
		    4'h5: hexTo7Seg = 7'b1011011;
		    4'h6: hexTo7Seg = 7'b1011111;
		    4'h7: hexTo7Seg = 7'b1110000;
		    4'h8: hexTo7Seg = 7'b1111111;
		    4'h9: hexTo7Seg = 7'b1111011;
		    4'ha: hexTo7Seg = 7'b1111101;
		    4'hb: hexTo7Seg = 7'b0011111;
		    4'hc: hexTo7Seg = 7'b1001110;
		    4'hd: hexTo7Seg = 7'b0111101;
		    4'he: hexTo7Seg = 7'b1001111;
		    4'hf: hexTo7Seg = 7'b1000111;
		endcase
	endfunction

endmodule