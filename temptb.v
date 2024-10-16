`timescale 1ns / 1ps

module Temperature_Monitor_tb;

    reg [7:0] temperature;
    wire temp_high;
    wire temp_state;
    wire temp_low;

    // Instantiate the Temperature Monitor
    Temperature_Monitor uut (
        .temperature(temperature),
        .temp_high(temp_high),
        .temp_state(temp_state),
        .temp_low(temp_low)
    );

    // Test task
    task test_temperature_monitor;
        integer i;
        reg [7:0] temp_value;
        begin
            $display("\nTemperature Monitor Test Cases");
            $display("+-------+-------------+-----------+------------+-----------+");
            $display("| Case  | Temperature | Temp State | Temp Low  | Temp High |");
            $display("+-------+-------------+-----------+------------+-----------+");

            for (i = 1; i <= 40; i = i + 1) begin
                temp_value = $urandom_range(85, 110);
                temperature = temp_value;
                #10;

                $display("| %3d   | %11d | %10b | %9b | %9b |", i, temp_value, temp_state, temp_high, temp_low);
            end

            $display("+-------+-------------+-----------+------------+-----------+");
        end
    endtask

    // Run the test
    initial begin
        test_temperature_monitor();
        $finish;
    end

endmodule
