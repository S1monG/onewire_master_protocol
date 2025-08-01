module onewire_reset (
    input wire clk,
    input wire enable,
    output reg drive_low,
    output reg sample,
    output reg done
);
    reg [$clog2(960*27):0] delay_counter;

    // Timing parameters
    localparam DRIVE_TIME = 480 * 27;
    localparam SAMPLE_POINT = 550 * 27;
    localparam TOTAL_TIME = 960 * 27;

    // Sample bus to determine if a device is present
    // Sample signal is high for one clock cycle, this is when top module should sample onewire
    // 0 = device present, 1 = no device present
    always @(posedge clk) begin
        if (!enable) begin
            delay_counter <= 0;
            drive_low <= 1'b0;
            sample <= 1'b0;
            done <= 1'b0;
        end else if (!done) begin
            delay_counter <= delay_counter + 1;
            drive_low <= (delay_counter < DRIVE_TIME);
            sample <= (delay_counter == SAMPLE_POINT);
            done <= (delay_counter >= TOTAL_TIME);
        end
        // If done and enable, hold all current values
    end

endmodule