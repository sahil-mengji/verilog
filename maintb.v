`timescale 1ns / 1ps

module TB_Combined;

    // Shared clock and reset signals
    reg clk;
    reg global_reset;

    // Instantiate all modules and their signals

    // BPM Monitor Testbench signals
    reg [7:0] pulse_count;  // Input pulse count
    wire [7:0] bpm;
    wire bpm_state;

    // Fall Detection Testbench signals
    reg fall_sensor;
    reg patient_reset;
    wire alarm;
    real fall_start_time;
    real fall_duration;

    // Medicine Reminder Testbench signals
    wire medicine_reminder;

    // Temperature Monitor Testbench signals
    reg [7:0] temperature;
    wire temp_high;
    wire temp_state;
    wire temp_low;

    // Instantiate all modules
    BPM_Monitor bpm_monitor_uut (
        .clk(clk),
        .reset(global_reset),
        .pulse_count(pulse_count),
        .bpm(bpm),
        .bpm_state(bpm_state)
    );

    fall_detection_system fall_detection_uut (
        .clk(clk),
        .reset(global_reset),
        .fall_sensor(fall_sensor),
        .patient_reset(patient_reset),
        .alarm(alarm)
    );

    Medicine_Reminder medicine_reminder_uut (
        .clk(clk),
        .reset(global_reset),
        .medicine_reminder(medicine_reminder)
    );

    Temperature_Monitor temperature_monitor_uut (
        .temperature(temperature),
        .temp_high(temp_high),
        .temp_state(temp_state),
        .temp_low(temp_low)
    );

    // Common clock generation for all modules (1 MHz clock => 1 μs period)
    initial begin
        clk = 0;
        forever #500 clk = ~clk;  // Toggle every 500 ns for 1 MHz clock
    end

    // Medicine Reminder Test Task
    task test_medicine_reminder;
        integer cycle_count;
        begin
            $display("\nMedicine Reminder Test Cases");
            $display("+-------+-------------------+-----------------+");
            $display("| Cycle | Time              | Medicine Reminder |");
            $display("+-------+-------------------+-----------------+");

            for (cycle_count = 0; cycle_count <= 2100; cycle_count = cycle_count + 1) begin
                @(posedge clk);  // Synchronize with positive clock edge
                #1;  // Small delay to allow for signal propagation
                $display("| %5d | %10d ns | %17b |", cycle_count, $time, medicine_reminder);
            end

            $display("+-------+-------------------+-----------------+");
        end
    endtask

    // Fall Detection Test Task
    task test_fall_detection;
        begin
            $display("\nFall Detection Test Cases");
            $display("+-----------------+-----------------+");
            $display("| Time            | Fall Sensor     |");
            $display("+-----------------+-----------------+-");

            // Initialize Inputs
            fall_sensor = 0;
            patient_reset = 0;

            // Test Case 1: No fall
            #1000000;  // Wait 1 second
            $display("| %0.2f seconds   | %b               |  ", 1.0,  fall_sensor);

            // Test Case 2: Fall detected, but patient resets before alarm
            fall_sensor = 1; // Simulate fall detection
            #10000;  // Wait for fall to be detected
            #5000000;  // Wait 5 seconds for the alarm to trigger

            // Check states
            $display("| %0.2f seconds   | %b               |  ", 6.0,  fall_sensor);
            patient_reset = 0; // Reset the patient
            #1000;
            patient_reset = 1; // Release the reset
            #1000; 
            fall_sensor = 1; // End the fall condition
            $display("| %0.2f seconds   | %b               |  ", 15.0,  fall_sensor);

            // Test Case 3: Fall detected, alarm triggered
            fall_sensor = 1; // Simulate fall detection
            #10000;  // Wait for fall to be detected
            #31000000;  // Wait 31 seconds for the alarm to trigger

            // Final check after the fall
            $display("| %0.2f seconds   | %b               |  ", 31.0,  fall_sensor);
            $display("+-----------------+-----------------+");
        end
    endtask

    // BPM Monitor Test Task
    task test_bpm_monitor;
        integer i;
        begin
            $display("\nBPM Monitor Test Cases");
            $display("+-------+--------+----------+");
            $display("| Pulse   | BPM    | State    |");
            $display("+-------+--------+----------+");

            // Loop over 35 test cases
            for (i = 1; i <= 35; i = i + 1) begin
                pulse_count = $urandom_range(5, 25);  // Random number of pulses between 5 and 25
                
                // Reset the system at the start of each test case
                global_reset = 1;
                #1000 global_reset = 0;  // Wait for reset to clear

                // Wait for clock cycles to propagate
                #1000;  // Wait for a clock cycle to process the pulse_count

                // Display the test results
                $display("| %6d | %6d | %8b |", pulse_count, bpm, bpm_state);
            end

            $display("+-------+--------+----------+");
        end
    endtask

    // Temperature Monitor Test Task
    task test_temperature_monitor;
        integer i;
        reg [7:0] temp_value;
        begin
            $display("\nTemperature Monitor Test Cases");
            $display("+-------+-------------+----------+");
            $display("| Temp  | Temp State  | Time     |");
            $display("+-------+-------------+----------+");

            for (i = 1; i <= 20; i = i + 1) begin
                temp_value = $urandom_range(95, 102);  // Adjusted range for more realistic temperatures
                temperature = temp_value;
                #1000;

                // Display the test results
                $display("| %5d | %10b  | %10d |", temp_value,  temp_high,  $time);
            end

            $display("+-------+-------------+----------+");
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        global_reset = 1;
        pulse_count = 0;
        temperature = 0;

        // De-assert reset after a short delay
        #1000 global_reset = 0;

        // Run all tests sequentially
        test_medicine_reminder();
        test_fall_detection();
        test_bpm_monitor();
        test_temperature_monitor();

        // End simulation
        $finish;
    end

endmodule
