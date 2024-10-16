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
