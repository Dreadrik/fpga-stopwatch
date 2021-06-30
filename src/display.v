// display holds 5 digits.
// It creates 5 single counts and wire them together so that when one overflows, the next is incremented.

`default_nettype none

module display
	#(
		parameter SEL_CE_DIV = 100_000,
		parameter SEG_CLK_BITS = 8
	)
	(
		input wire clk, 
		input wire  [5*4-1:0] digits,
		output wire seg_clk,
		output wire [7:0] segments,
		output wire [4:0] cathodes
	);

	// Clock enable for digit selection multiplexer
	wire sel_ce;
	clock_enable #(.DIV(SEL_CE_DIV)) ce0(.clk(clk), .reset(1'b0), .clk_enable(sel_ce));

	// Digit selection counter
	reg [2:0] sel = 3'd0;
	wire sel_rollover = (sel == 3'd4);
	always @(posedge clk) begin
		if (sel_ce) 
			sel <= (sel_rollover) ? 3'd0 : sel + 3'd1;
	end

	// Digit selection
	wire [3:0] digit;
	assign digit = digitSel(sel, digits);

	// 7-segment decoder
	assign segments = bcdTo7Seg(digit);

	// Active cathode selection
	assign cathodes[0] = (sel == 3'd0);
	assign cathodes[1] = (sel == 3'd1);
	assign cathodes[2] = (sel == 3'd2);
	assign cathodes[3] = (sel == 3'd3);
	assign cathodes[4] = (sel == 3'd4);

	// Segment update clock
	reg [SEG_CLK_BITS - 1:0] segclk = 0;
	always @(posedge clk) begin
		segclk <= segclk + 1;
	end
	assign seg_clk = segclk[SEG_CLK_BITS - 1];	// Divide 100 Mhz clock by 256 gives ~290kHz

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