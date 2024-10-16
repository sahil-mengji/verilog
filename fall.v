module fall_detection_system(
    input wire clk,
    input wire reset,
    input wire fall_sensor,
    input wire patient_reset,
    output reg alarm
);

    // Parameters
    parameter STABLE_TIME = 5;  // Time to confirm stable fall signal (in clock cycles)
    parameter RECOVERY_TIME = 30;  // Recovery time in seconds

    // State definition
    localparam IDLE = 2'b00;
    localparam FALL_DETECTED = 2'b01;
    localparam RECOVERY = 2'b10;

    // Registers
    reg [1:0] state;
    reg [31:0] timer;
    reg [31:0] clock_counter;

    // Assume 1 MHz clock for 1 second timing
    localparam CLOCKS_PER_SECOND = 1000000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            timer <= 0;
            alarm <= 0;
            clock_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (fall_sensor) begin
                        state <= FALL_DETECTED;
                        timer <= 0;
                    end
                end

                FALL_DETECTED: begin
                    if (!fall_sensor) begin
                        state <= IDLE;
                    end else if (timer == STABLE_TIME - 1) begin
                        state <= RECOVERY;
                        timer <= 0;
                        clock_counter <= 0;
                    end else begin
                        timer <= timer + 1;
                    end
                end

                RECOVERY: begin
                    if (patient_reset) begin
                        state <= IDLE;
                        alarm <= 0;
                    end else if (clock_counter == CLOCKS_PER_SECOND - 1) begin
                        if (timer == RECOVERY_TIME - 1) begin
                            alarm <= 1;
                        end else begin
                            timer <= timer + 1;
                        end
                        clock_counter <= 0;
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule