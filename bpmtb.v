module TB_BPM_Monitor;

    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] pulse_count;  // Input pulse count
    wire [7:0] bpm;
    wire bpm_state;

    // Instantiate the BPM_Monitor module
    BPM_Monitor uut (
        .clk(clk),
        .reset(reset),
        .pulse_count(pulse_count), // Connect pulse_count
        .bpm(bpm),
        .bpm_state(bpm_state)
    );

    // Clock generation (50 MHz)
    always begin
        #10 clk = ~clk;  // Clock period = 20 time units
    end

    // Task to test the BPM monitor with random pulse counts
    task test_bpm_monitor;
        integer i;
        begin
            $display("\nBPM Monitor Test Cases");
            $display("+-------+--------------+--------+-----------+");
            $display("| Case  | Pulse Count  | BPM    | BPM State |");
            $display("+-------+--------------+--------+-----------+");

            // Loop over 35 test cases
            for (i = 1; i <= 35; i = i + 1) begin
                pulse_count = $urandom_range(5, 25);  // Random number of pulses between 5 and 25
                
                // Reset the system at the start of each test case
                reset = 1;
                #20 reset = 0;

                // Wait for clock edges to propagate
                #20;  // Wait for a clock cycle to process the pulse_count

                // Display the test results
                $display("| %3d   | %12d | %6d | %9b |", i, pulse_count, bpm, bpm_state);
            end

            $display("+-------+--------------+--------+-----------+");
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        pulse_count = 0;

        // Call the test task
        test_bpm_monitor();

        // End simulation
        $finish;
    end

endmodule
