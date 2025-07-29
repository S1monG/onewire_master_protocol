module onewire_write (
    input wire clk,
    input wire [7:0] operation,
    input wire enable,
    output reg done,
    output reg drive_low
);
    localparam WRITE = 3'b001;

    reg [$clog2(70*27):0] delay_counter = 0;
    reg [3:0] op_idx = 4'd0;

    always @(posedge clk) begin
        if (enable & !done) begin
            if (op_idx < 4'd8) begin
                if (operation[op_idx]) begin // write 1
                    if (delay_counter < 6*27) begin
                        delay_counter <= delay_counter + 1;
                        drive_low <= 1'b1; // Drive low
                    end else if (delay_counter < 64*27) begin
                        delay_counter <= delay_counter + 1;
                        drive_low <= 1'b0; // Release bus
                    end else begin
                        delay_counter <= 0;
                        op_idx <= op_idx + 1;
                    end
                end else begin // write 0
                    if (delay_counter < 60*27) begin
                        delay_counter <= delay_counter + 1;
                        drive_low <= 1'b1; // Drive low
                    end else if (delay_counter < 70*27) begin
                        delay_counter <= delay_counter + 1;
                        drive_low <= 1'b0; // Release bus
                    end else begin
                        delay_counter <= 0;
                        op_idx <= op_idx + 1;
                    end
                end
            end else begin
                done <= 1'b1;
            end
        end else if (!enable) begin
            done <= 1'b0;
        end
    end 

endmodule