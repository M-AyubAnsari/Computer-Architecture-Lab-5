`timescale 1ns / 1ps

module leds(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,

    output reg [31:0] readData = 0,
    output reg [15:0] leds
);

parameter LED_ADDR = 30'h00000004;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        leds <= 16'd0;
    end
    else begin
        if (writeEnable && memAddress == LED_ADDR) begin
            leds <= writeData[15:0];
        end
    end
end

always @(*) begin
    if (readEnable && memAddress == LED_ADDR)
        readData = {16'd0, leds};
    else
        readData = 32'd0;
end

endmodule
