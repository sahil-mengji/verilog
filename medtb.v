`timescale 1ns / 1ps

module Medicine_Reminder_tb;

    reg clk;
    reg reset;
    wire medicine_reminder;

    // Instantiate the Medicine Reminder
    Medicine_Reminder uut (
        .clk(clk),
        .reset(reset),
        .medicine_reminder(medicine_reminder)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1; // Assert reset
        #10; // Wait for a few cycles
        reset = 0; // Deassert reset

        // Run the test
        test_medicine_reminder();

        // Finish simulation
        $finish;
    end

    // Medicine Reminder test task
    task test_medicine_reminder;
        integer i;
        reg [31:0] on_time;
        reg [31:0] last_reminder_time;
        reg [31:0] check_time;

        begin
            $display("\nMedicine Reminder Test Cases");
            $display("+-------+-------------------+-----------------+");
            $display("| Case  | Time              | Medicine Reminder |");
            $display("+-------+-------------------+-----------------+");

            last_reminder_time = 0; // Initialize the last reminder time

            for (check_time = 0; check_time <= 10000; check_time = check_time + 5) begin
                #5; // Wait for the next 5 ns

                // Check if the medicine reminder is currently active
                if (medicine_reminder) begin
                    // Calculate how long it has been on since the last reminder
                    on_time = $time - last_reminder_time;

                    // Update last_reminder_time if it was just activated
                    if (last_reminder_time == 0 || last_reminder_time == $time - 1000) begin
                        last_reminder_time = $time;
                    end
                end else begin
                    on_time = 0;
                end

                // Display the current case results every 5 ns
                $display("| %3d   | %10dns | %17b |", check_time / 5, $time, medicine_reminder);
            end

            $display("+-------+-------------------+-----------------+");
        end
    endtask

    // Monitor outputs
    initial begin
        $monitor("Time: %0dns | Medicine Reminder: %b", $time, medicine_reminder);
    end

endmodule
