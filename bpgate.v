module BPM_Monitor (
    input wire [7:0] pulse_count,  // 8-bit pulse count input
    input wire clk,                // Clock
    input wire reset,              // Reset
    output wire [7:0] bpm,         // BPM (pulse count * 6)
    output wire bpm_state          // 1 if pulse_count < 10 or pulse_count > 17, else 0
);

    // Wires for intermediate results
    wire [7:0] shift_left1;  // pulse_count << 1
    wire [7:0] shift_left2;  // pulse_count << 2
    wire [7:0] add_result;   // (pulse_count << 1) + (pulse_count << 2)

    // Step 1: Shifting using gate-level primitives

    // Shift left by 1 (multiply by 2)
    assign shift_left1[7] = pulse_count[6];
    assign shift_left1[6] = pulse_count[5];
    assign shift_left1[5] = pulse_count[4];
    assign shift_left1[4] = pulse_count[3];
    assign shift_left1[3] = pulse_count[2];
    assign shift_left1[2] = pulse_count[1];
    assign shift_left1[1] = pulse_count[0];
    assign shift_left1[0] = 0;  // Shift in a 0

    // Shift left by 2 (multiply by 4)
    assign shift_left2[7] = pulse_count[5];
    assign shift_left2[6] = pulse_count[4];
    assign shift_left2[5] = pulse_count[3];
    assign shift_left2[4] = pulse_count[2];
    assign shift_left2[3] = pulse_count[1];
    assign shift_left2[2] = pulse_count[0];
    assign shift_left2[1] = 0;  // Shift in two 0's
    assign shift_left2[0] = 0;

    // Adding using OR gates
    or (bpm[0], shift_left1[0], shift_left2[0]);  // bit 0
    or (bpm[1], shift_left1[1], shift_left2[1]);  // bit 1
    or (bpm[2], shift_left1[2], shift_left2[2]);  // bit 2
    or (bpm[3], shift_left1[3], shift_left2[3]);  // bit 3
    or (bpm[4], shift_left1[4], shift_left2[4]);  // bit 4
    or (bpm[5], shift_left1[5], shift_left2[5]);  // bit 5
    or (bpm[6], shift_left1[6], shift_left2[6]);  // bit 6
    or (bpm[7], shift_left1[7], shift_left2[7]);  // bit 7

    // Step 2: Comparators for bpm_state

    // Checking if pulse_count < 10
    wire not_pulse_count_3, not_pulse_count_2, not_pulse_count_1, not_pulse_count_0;
    wire lt_10_cond1, lt_10_cond2, lt_10;

    // NOT gates for lower bits of pulse_count
    not (not_pulse_count_3, pulse_count[3]);
    not (not_pulse_count_2, pulse_count[2]);
    not (not_pulse_count_1, pulse_count[1]);
    not (not_pulse_count_0, pulse_count[0]);

    // AND gates for pulse_count < 10
    and (lt_10_cond1, not_pulse_count_3, not_pulse_count_2);
    and (lt_10_cond2, not_pulse_count_1, not_pulse_count_0);
    and (lt_10, lt_10_cond1, lt_10_cond2);

    // Checking if pulse_count > 17
    wire gt_17_cond1, gt_17_cond2, gt_17_cond3, gt_17;

    // OR gates for pulse_count > 17
    or (gt_17_cond1, pulse_count[4], pulse_count[5], pulse_count[6], pulse_count[7]);
    or (gt_17_cond3, pulse_count[2], pulse_count[1], pulse_count[0]);

    // AND gate to combine conditions
    and (gt_17_cond2, pulse_count[3], gt_17_cond3);

    // Final OR gate for pulse_count > 17
    or (gt_17, gt_17_cond1, gt_17_cond2);

    // OR gate to combine lt_10 and gt_17 for bpm_state
    or (bpm_state, lt_10, gt_17);

endmodule
