`timescale 1ns / 1ps
module FiniteStateMachine(
    input wire clk,
    input wire rst,
    input wire start,

    // Memory bus
    output reg [29:0] memAddress,
    output reg readEnable,
    output reg writeEnable,
    output reg [31:0] writeData,
    input  wire [31:0] readData
);

    // Encoding the states of the FSM.
    parameter S0_IDLE      = 2'd0;
    parameter S1_LOAD      = 2'd1;
    parameter S2_COUNTDOWN = 2'd2;

    reg [1:0] state, next_state;
    reg [15:0] count;

    // Address map
    parameter SWITCH_ADDR = 30'h00000000;
    parameter LED_ADDR    = 30'h00000004;

    // State Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        next_state = state;

        case (state)

            S0_IDLE:
                if (start)
                    next_state = S1_LOAD;

            S1_LOAD:
                next_state = S2_COUNTDOWN;

            S2_COUNTDOWN:
                if (count == 16'd0)
                    next_state = S0_IDLE;

            default:
                next_state = S0_IDLE;

        endcase
    end

    // Output & Counter Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count       <= 16'd0;
            memAddress  <= 30'd0;
            readEnable  <= 0;
            writeEnable <= 0;
            writeData   <= 32'd0;
        end
        else begin

            // Default bus signals
            readEnable  <= 0;
            writeEnable <= 0;

            case (state)

                S0_IDLE: begin
                    memAddress <= SWITCH_ADDR;
                    readEnable <= 1;
                    count <= 16'd0;
                end

                S1_LOAD: begin
                    count <= readData[15:0];
                end

                S2_COUNTDOWN: begin
                    memAddress  <= LED_ADDR;
                    writeData   <= {16'd0, count};
                    writeEnable <= 1;

                    if (count > 0)
                        count <= count - 1;
                end

            endcase
        end
    end

endmodule

