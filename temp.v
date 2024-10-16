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
