module onewire_write ( // TODO: make generic number of writes with parameters
    input wire clk,
    input wire [7:0] operation,
    input wire enable,
    output reg done,
    output reg drive_low
);
    reg [$clog2(70*27):0] delay_counter;
    reg [3:0] op_idx;

    localparam WRITE_1_DRIVE_TIME = 6 * 27;
    localparam WRITE_0_DRIVE_TIME = 60 * 27;
    localparam TOTAL_TIME = 70 * 27;

    always @(posedge clk) begin
        if (!enable) begin
            delay_counter <= 0;
            op_idx <= 4'd0;
            drive_low <= 1'b0;
            done <= 1'b0;
        end else if (op_idx == 4'd8) begin
            done <= 1'b1;
        end else if (!done) begin
            drive_low <= (operation[op_idx] ? 
                (delay_counter < WRITE_1_DRIVE_TIME) : 
                (delay_counter < WRITE_0_DRIVE_TIME));
            if (delay_counter >= TOTAL_TIME) begin
                delay_counter <= 0;
                op_idx <= op_idx + 1;
            end else begin
                delay_counter <= delay_counter + 1;
            end
        end
    end

endmodule