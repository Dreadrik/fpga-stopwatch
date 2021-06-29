`default_nettype none

module bcd_digit
	#( 
		parameter ROLLOVER = 9
	)
	(
		input wire clk, reset, inc, 
		output reg [3:0] digit = 4'd0, 
		output wire carryout
	);

	wire rollover = (digit == ROLLOVER);
	always @(posedge clk) begin
		if (reset) 
			digit <= 4'd0;
		else if (inc) 
			digit <= (rollover) ? 4'd0 : digit + 4'd1;
	end

	assign carryout = inc & rollover;
endmodule
