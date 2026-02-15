`timescale 1ns / 1ps
module TopFSMModule(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] switches,
    output wire [15:0] leds_out
);

    wire [15:0] count;

    FiniteStateMachine fsm_inst (
        .clk(clk),
        .rst(rst),
        .switch_value(switches),
        .count(count)
    );

    // LEDs reflect counter value
    assign leds_out = count;

endmodule
