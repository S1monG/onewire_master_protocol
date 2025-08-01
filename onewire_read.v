module onewire_read ( // TODO: rename onewire_read_byte or make generic number of samples with parameters
    input wire clk,
    input wire enable,
    output reg drive_low,
    output reg done,
    output reg sample,
    output reg [3:0] sample_idx
);
    reg [$clog2(70*27):0] delay_counter = 0;

    localparam DRIVE_TIME = 6 * 27;
    localparam SAMPLE_TIME = 15 * 27;
    localparam TOTAL_TIME = 70 * 27;

    // Sample signal is high one cycle every 70us
    // It dictates when top module should sample onewire to get a reading
    // After 8 samples, the process stops
    always @(posedge clk) begin
        if (!enable) begin
            delay_counter <= 0;
            sample_idx <= 4'd0;
            sample <= 1'b0;
            drive_low <= 1'b0;
            done <= 1'b0;
        end else if (sample_idx == 4'd8) begin
            done <= 1'b1;
        end else if (!done) begin
            drive_low <= (delay_counter < DRIVE_TIME);
            sample <= (delay_counter == SAMPLE_TIME);
            if (delay_counter >= TOTAL_TIME) begin
                delay_counter <= 0;
                sample_idx <= sample_idx + 1;
            end else begin
                delay_counter <= delay_counter + 1;
            end
        end
        // If done and enable, hold all current values
    end
endmodule