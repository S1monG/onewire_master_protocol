module onewire_reset (
    input wire clk,
    input wire enable,
    output reg drive_low,
    output reg sample,
    output reg done
);
    reg [$clog2(960*27):0] delay_counter = 0;

    // Sample bus to determine if a device is present
    // Sample signal is high for one clock cycle, this is when top module should sample onewire
    // 0 = device present, 1 = no device present
    always @(posedge clk) begin
        if (enable & !done) begin
            if (delay_counter < 480*27) begin
                delay_counter <= delay_counter + 1;
                drive_low <= 1'b1;
            end else if (delay_counter < 550*27) begin
                delay_counter <= delay_counter + 1;
                drive_low <= 1'b0;
            end else if (delay_counter == 550*27) begin
                sample <= 1'b1;
            end else if (delay_counter < 960*27) begin
                delay_counter <= delay_counter + 1;
                sample <= 1'b0;
            end else begin
                done <= 1'b1;
                delay_counter <= 0;
            end
        end else if (!enable) begin
            done <= 1'b0;
        end
    end

endmodule