`default_nettype none

module clock_enable
	#( 
		parameter DIV = 1_000_000
	)
	(
		input wire clk, reset, 
		output wire clk_enable
	);

	localparam WIDTH = $clog2(DIV);
	reg [WIDTH - 1:0] cnt = 0;

	wire rollover = (cnt == DIV - 1);

	always @(posedge clk) begin
		if (reset)
			cnt <= 0;
		else
			cnt <= (rollover) ? 0 : cnt + 1;
	end
	
	assign clk_enable = rollover ? 1'b1 : 1'b0;

endmodule