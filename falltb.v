`timescale 1us/1ns

module fall_detection_system_tb;

    // Inputs
    reg clk;
    reg reset;
    reg fall_sensor;
    reg patient_reset;

    // Outputs
    wire alarm;

    // Testbench variables
    real fall_start_time;
    real fall_duration;
    real reset_time;
    
    // Monitor variable
    reg [31:0] monitor_time;

    // Instantiate the Unit Under Test (UUT)
    fall_detection_system uut (
        .clk(clk), 
        .reset(reset), 
        .fall_sensor(fall_sensor), 
        .patient_reset(patient_reset), 
        .alarm(alarm)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk; // 1 MHz clock
    end

    // Monitor time update
    always @(posedge clk) begin
        monitor_time <= $realtime / 1000000;
    end

    // Test scenario
    initial begin
        // Initialize Inputs
        reset = 1;
        fall_sensor = 0;
        patient_reset = 0;
        fall_start_time = 0;
        fall_duration = 0;
        reset_time = 0;

        // Wait for global reset
        #10;
        reset = 0;

        // Test Case 1: No fall
        #1000000; // Wait 1 second

        // Test Case 2: Fall detected, but patient resets before alarm
        fall_sensor = 1;
        fall_start_time = $realtime/1000000.0;
        #10; // Wait for fall to be detected
        #5000000; // Wait 5 seconds
        fall_duration = ($realtime/1000000.0) - fall_start_time;
        patient_reset = 1;
        reset_time = ($realtime/1000000.0) - fall_start_time;
        #1;
        patient_reset = 0;
        #1;
        fall_sensor = 0;
        $display("Test Case 2: Fall duration = %0.2f seconds, Reset pressed after %0.2f seconds", fall_duration, reset_time);

        // Wait a bit
        #1000000;

        // Test Case 3: Fall detected, alarm triggered
        fall_sensor = 1;
        fall_start_time = $realtime/1000000.0;
        #10; // Wait for fall to be detected
        #31000000; // Wait 31 seconds
        fall_duration = ($realtime/1000000.0) - fall_start_time;
        $display("Test Case 3: Fall duration = %0.2f seconds, No reset pressed", fall_duration);

        // End simulation
        #1000000;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0d s: fall_sensor=%b, patient_reset=%b, alarm=%b", 
                 monitor_time, fall_sensor, patient_reset, alarm);
    end

endmodule