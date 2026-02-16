`timescale 1ns / 1ps

module switches(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,

    output reg [31:0] readData
);

parameter SWITCH_ADDR = 30'h00000000;

always @(*) begin
    if (readEnable && memAddress == SWITCH_ADDR)
        readData = {16'd0, switches};
    else
        readData = 32'd0;
end

endmodule
