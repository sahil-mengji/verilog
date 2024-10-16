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
