`timescale 1ns / 1ps
module TopFSMModule(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] switches,
    input  wire [15:0] btns,   // not used but must remain for interface
    output wire [15:0] leds_out
);

    // Bus signals
    wire [31:0] writeData;
    wire [31:0] readData;
    wire [29:0] memAddress;
    wire writeEnable;
    wire readEnable;

    wire [31:0] switchReadData;
    wire [31:0] ledReadData;

    // FSM
    FiniteStateMachine fsm_inst (
        .clk(clk),
        .rst(rst),
        .memAddress(memAddress),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .readData(readData)
    );

    // Provided Switch Module
    switches sw_inst (
        .clk(clk),
        .rst(rst),
        .btns(btns),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(readEnable),
        .memAddress(memAddress),
        .switches(switches),
        .readData(switchReadData)
    );

    // Provided LED Module 
    leds led_inst (
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(writeEnable),
        .readEnable(readEnable),
        .memAddress(memAddress),
        .readData(ledReadData),
        .leds(leds_out)
    );

    // Bus multiplexer
    assign readData =
        (memAddress == 30'h00000000) ? switchReadData :
        (memAddress == 30'h00000004) ? ledReadData :
        32'b0;

endmodule
