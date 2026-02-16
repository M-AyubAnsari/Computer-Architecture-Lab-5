`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg rst;
    reg [15:0] switches;
    reg [15:0] btns;
    wire [15:0] leds_out;

    TopFSMModule uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .btns(btns),
        .leds_out(leds_out)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        switches = 0;
        btns = 0;

        #20;
        rst = 0;

        // Load value 5
        switches = 16'd5;
        #400;

        // Load value 3
        switches = 16'd3;
        #300;

        // Reset during countdown
        switches = 16'd10;
        #50;
        rst = 1;
        #20;
        rst = 0;

        #300;

        $stop;
    end

endmodule
