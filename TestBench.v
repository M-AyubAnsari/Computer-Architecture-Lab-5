`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg rst;
    reg [15:0] switches;
    wire [15:0] leds_out;

    // Instantiate DUT
    TopFSMModule uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .leds_out(leds_out)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        switches = 0;

        // Release reset
        #20;
        rst = 0;

        // Test 1: Load 5
        switches = 16'd5;
        #200;   // wait for countdown

        // Clear switches (should be ignored during countdown)
        switches = 0;
        #100;

        // Test 2: Load 3

        switches = 16'd3;
        #150;

        // Test 3: Reset during countdown
        switches = 16'd10;
        #30;
        rst = 1;   // reset mid-count
        #20;
        rst = 0;

        #100;

        $stop;
    end

endmodule
