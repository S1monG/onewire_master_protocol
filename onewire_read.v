module onewire_read ( // TODO: rename onewire_read_byte or make generic number of samples with parameters
    input wire clk,
    input wire enable,
    output reg drive_low,
    output reg done,
    output reg sample
);
    reg [$clog2(70*27):0] delay_counter = 0;
    reg [3:0] bit_idx = 4'd0;

    // Sample signal is high one cycle every 70us
    // It dictates when top module should sample onewire to get a reading
    // After 8 samples, the process stops
    always @(posedge clk) begin
        if (enable & !done) begin
            if (bit_idx < 4'd8) begin
                if (delay_counter < 6*27) begin
                    delay_counter <= delay_counter + 1;
                    drive_low <= 1'b1;
                end else if (delay_counter < 15*27) begin
                    delay_counter <= delay_counter + 1;
                    drive_low <= 1'b0;
                end else if (delay_counter == 15*27) begin
                    delay_counter <= delay_counter + 1;
                    sample <= 1'b1;
                end else if (delay_counter < 70*27) begin
                    sample <= 1'b0;
                    delay_counter <= delay_counter + 1;
                end else begin
                    delay_counter <= 0;
                    bit_idx <= bit_idx + 1;
                end
            end else begin
                done <= 1'b1;
            end
        end else if (!enable) begin
            done <= 1'b0;
        end
    end
endmodule