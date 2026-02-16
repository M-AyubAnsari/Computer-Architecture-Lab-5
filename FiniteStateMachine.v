`timescale 1ns / 1ps
module FiniteStateMachine(
    input wire clk,
    input wire rst,

    // Memory bus
    output reg [29:0] memAddress,
    output reg readEnable,
    output reg writeEnable,
    output reg [31:0] writeData,
    input  wire [31:0] readData
);

    // FSM States
    parameter S0_WAIT      = 2'd0;
    parameter S1_READ      = 2'd1;
    parameter S2_LATCH     = 2'd2;
    parameter S3_COUNTDOWN = 2'd3;

    reg [1:0] state, next_state;

    reg [15:0] count;
    reg [15:0] switch_value;

    // Address map
    parameter SWITCH_ADDR = 30'h00000000;
    parameter LED_ADDR    = 30'h00000004;

    // State Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_WAIT;
        else
            state <= next_state;
    end

    // Next-State Logic
    always @(*) begin
        next_state = state;

        case (state)

            // Continuously checking switches
            S0_WAIT:
                next_state = S1_READ;

            // Wait one cycle for valid readData
            S1_READ:
                if (readData[15:0] != 16'd0)
                    next_state = S2_LATCH;
                else
                    next_state = S0_WAIT;

            // Capture switch value once
            S2_LATCH:
                next_state = S3_COUNTDOWN;

            // Count down until zero
            S3_COUNTDOWN:
                if (count == 16'd0)
                    next_state = S0_WAIT;

            default:
                next_state = S0_WAIT;
        endcase
    end

    // Output & Counter Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count        <= 16'd0;
            switch_value <= 16'd0;
            memAddress   <= 30'd0;
            readEnable   <= 0;
            writeEnable  <= 0;
            writeData    <= 32'd0;
        end
        else begin
            // Default read and write signals
            readEnable  <= 0;
            writeEnable <= 0;

            case (state)

                // Request switch value
                S0_WAIT: begin
                    memAddress <= SWITCH_ADDR;
                    readEnable <= 1;
                end

                // Give bus one clock to respond
                S1_READ: begin
                    memAddress <= SWITCH_ADDR;
                    readEnable <= 1;
                end

                // Now data is valid, latch it
                S2_LATCH: begin
                    switch_value <= readData[15:0];
                    count        <= readData[15:0];
                end

                // Countdown & LEDs
                S3_COUNTDOWN: begin
                    memAddress  <= LED_ADDR;
                    writeEnable <= 1;
                    writeData   <= {16'd0, count};

                    if (count > 0)
                        count <= count - 1;
                end
            endcase
        end
    end

endmodule
