`default_nettype none

module debounce
    #(
        parameter DIV = 500_000
    )
    (
        input wire clk, 
        input wire button, 
        output out
    );
    
    wire slow_clk_en;
    wire Q0, Q1, Q2, nQ2;

    clock_enable #(.DIV(DIV)) ce0(.clk(clk), .reset(1'b0), .clk_enable(slow_clk_en));
    my_dff_en d0(.clk(clk), .clock_enable(slow_clk_en), .D(button), .Q(Q0));
    my_dff_en d1(.clk(clk), .clock_enable(slow_clk_en), .D(Q0), .Q(Q1));
    my_dff_en d2(.clk(clk), .clock_enable(slow_clk_en), .D(Q1), .Q(Q2));

    assign nQ2 = ~Q2;
    assign out = Q1 & nQ2;
endmodule

// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(
    input wire clk, 
    input wire clock_enable, 
    input wire D, 
    output reg Q = 0);

    always @ (posedge clk) begin
        if (clock_enable) 
            Q <= D;
    end
endmodule