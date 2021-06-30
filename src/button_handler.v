`default_nettype none

module button_handler 
	#(
		parameter DBNC_DIV = 500_000
	)
	(
		input wire clk,    // Clock
		input wire button,
		output wire clear,
		output wire prepare_start,
		output wire running
	);

	wire btn_tap;
	debounce 
		#(
			.DIV(DBNC_DIV)
		) 
		dbnc(
			.clk(clk), 
			.button(button), 
			.out(btn_tap)
		);

	// State machine
	localparam 
		resetted 	= 3'd0,
		starting 	= 3'd1,
		started 	= 3'd2,
		stopping 	= 3'd3,
		stopped 	= 3'd4,
		resetting 	= 3'd5;

	reg [2:0] 
		state = resetting,
		next_state = resetting;

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

	always @(posedge clk) begin
		state = next_state;
	end

	assign clear = (state == resetting);
	assign prepare_start = (state == starting);
	assign running = (state == started);
endmodule
