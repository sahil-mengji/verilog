module BPM_Monitor(
    input wire clk,
    input wire reset,
    input wire [7:0] pulse_count, // Random integer input representing pulse count
    output reg [7:0] bpm,          // BPM value (after multiplying by 6)
    output reg bpm_state           // Output 1 if pulse count < 10 or pulse count > 17, else 0
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bpm <= 0;
            bpm_state <= 0;
        end
        else begin
            // Calculate BPM based on the pulse count input
            bpm <= pulse_count * 6;  // Multiply the pulse count by 6 to get BPM

            // Check if pulse count is outside the range 10-17
            if (pulse_count < 10 || pulse_count > 17) begin
                bpm_state <= 1;  // Abnormal
            end
            else begin
                bpm_state <= 0;  // Normal
            end
        end
    end
endmodule


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

module Temperature_Monitor(
    input wire [7:0] temperature,
    output wire temp_high,
    output wire temp_state,
    output wire temp_low
);

// High temperature threshold logic
assign temp_high = (temperature < 8'd97 || temperature > 8'd100) ? 1'b1 : 1'b0;

// Determine if the temperature is critically high
assign temp_state = (temperature > 8'd100) ? 1'b1 : 1'b0;

// Low temperature threshold logic
assign temp_low = (temperature < 8'd90) ? 1'b1 : 1'b0;

endmodule


module Medicine_Reminder(
    input wire clk,
    input wire reset,
    output reg medicine_reminder
);

reg [11:0] counter; // Counter for time intervals (up to 600 for 10 minutes)
reg [3:0] medicine_counter; // Medicine reminder count
reg [23:0] reminder_timer; // Timer for how long to keep reminder on (10 seconds)

// Parameters
parameter CYCLES_PER_10_MINUTES = 600; // Clock cycles for 10 minutes
parameter CYCLES_FOR_10_SECONDS = 100;  // Assuming 10s at 100 MHz

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 12'b0;
        medicine_counter <= 4'b0;
        medicine_reminder <= 1'b0;
        reminder_timer <= 24'b0;
    end else begin
        // Check if 600 clock cycles have passed
        if (counter == CYCLES_PER_10_MINUTES) begin
            counter <= 12'b0; // Reset the counter
            if (medicine_counter < 4'd3) begin // Allow reminders for 3 cycles
                medicine_reminder <= 1'b1; // Trigger reminder
                medicine_counter <= medicine_counter + 1'b1; // Increment medicine counter
                reminder_timer <= 24'b0; // Reset reminder timer
            end else begin
                medicine_reminder <= 1'b0; // Reset reminder after all medicine reminders
            end
        end else begin
            counter <= counter + 1'b1; // Increment main counter
            
            // Timer logic to turn off reminder after 10 seconds
            if (medicine_reminder) begin
                if (reminder_timer < CYCLES_FOR_10_SECONDS) begin
                    reminder_timer <= reminder_timer + 1'b1; // Increment reminder timer
                end else begin
                    medicine_reminder <= 1'b0; // Turn off reminder after 10 seconds
                end
            end
        end
    end
end

endmodule
