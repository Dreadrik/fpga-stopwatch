`timescale 1 us/1 ns 

`default_nettype none

module stopwatch_tb;
    
    reg clk, button;
    wire [7:0] segments;
    wire segclk;
    wire [4:0] cathodes;

    stopwatch 
        #(
            .SEL_CE_DIV(10),
            .INC_CE_DIV(50),
            .SEG_CLK_BITS(2),
            .DBNC_DIV(8)
        )
        uut
        (
            .SYSCLK(clk),
            .BTN(button),
            .SEGA(segments[7]), 
            .SEGB(segments[6]), 
            .SEGC(segments[5]), 
            .SEGD(segments[4]), 
            .SEGE(segments[3]), 
            .SEGF(segments[2]), 
            .SEGG(segments[1]), 
            .SEGDP(segments[0]),
            .SEGCLK(segclk),
            .SEGCAT(cathodes)
        );

    initial begin
        $dumpfile("stopwatch_tb");
        $dumpvars(0, stopwatch_tb);

        #10_000 $finish;
    end

    initial begin
        clk = 1'b0;
        button = 1'b1;
        #1000
        button = 1'b0;
        #400
        button = 1'b1;
        #1000
        button = 1'b0;
        #400
        button = 1'b1;
        #1000
        button = 1'b0;
        #400
        button = 1'b1;
    end

    initial forever clk = #5 ~clk;

endmodule