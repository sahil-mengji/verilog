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
        reset = 1;
        #10 reset = 0;
        test_medicine_reminder();
        $finish;
    end

    // Medicine Reminder test task
    task test_medicine_reminder;
        integer cycle_count;
        begin
            $display("\nMedicine Reminder Test Cases");
            $display("+-------+-------------------+-----------------+");
            $display("| Cycle | Time              | Medicine Reminder |");
            $display("+-------+-------------------+-----------------+");

            for (cycle_count = 0; cycle_count <= 2100; cycle_count = cycle_count + 1) begin
                @(posedge clk); // Synchronize with positive clock edge
                #1; // Small delay to allow for signal propagation
                $display("| %5d | %10d ns | %17b |", cycle_count, $time, medicine_reminder);
            end

            $display("+-------+-------------------+-----------------+");
        end
    endtask

    // Monitor outputs
    initial begin
        $monitor("Time: %0d ns | Medicine Reminder: %b", $time, medicine_reminder);
    end

endmodule