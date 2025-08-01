`include "onewire_write.v"
`include "onewire_read.v"
`include "onewire_reset.v"

// Implements a FSM from IDLE -> RESET -> WRITE -> READ -> IDLE 
// The process is started when rst_n is low, and keeps running until back to IDLE, i.e it cannot be stopped once running
// Individual submodules reset their done variable when enable is low
module onewire_master (
    input wire clk, // 27 MHz clock, 1us = 27 clock cycles, TODO: make clk freq a parameter
    input wire rst_n,
    inout wire onewire
);
    localparam IDLE = 2'b00;
    localparam RESET = 2'b01;
    localparam WRITE = 2'b10;
    localparam READ = 2'b11;

    reg [1:0] state, next;

    wire write_done, read_done, reset_done;
    wire reset_sample, read_sample;
    reg device_present; // TODO: Do something with if device not present
    reg [7:0] data_out; 
    wire [3:0] data_out_idx; // idx will always be <8. It is 4 bits wide because that makes the read module easier.


    // State transition logic
    always @(*) begin
        case (state)
            IDLE: next = (!rst_n) ? RESET : IDLE;
            RESET: next = (reset_done) ? WRITE : RESET;
            WRITE: next = (write_done) ? READ : WRITE;
            READ: next = (read_done) ? IDLE : READ;
        endcase
    end

    // State flip-flops
    always @(posedge clk) begin
        case (state)
            RESET: if (reset_sample) device_present <= (onewire == 1'b0);
            READ: if (read_sample) data_out[data_out_idx] <= onewire;
        endcase
        state <= next;
    end

    wire reset_enable, write_enable, read_enable; 
    assign reset_enable = (state == RESET);
    assign write_enable = (state == WRITE);
    assign read_enable = (state == READ);

    wire reset_drive_low, write_drive_low, read_drive_low;
    wire drive_low;
    assign drive_low = (reset_enable & reset_drive_low) | (read_enable & read_drive_low) | (write_enable & write_drive_low); // max one of the enables will be high at any given time
    assign onewire = drive_low ? 1'b0 : 1'bz;

    wire [7:0] operation;
    assign operation = 8'b10101010;

    onewire_reset reset (
        .clk(clk),
        .enable(reset_enable),
        .drive_low(reset_drive_low),
        .sample(reset_sample),
        .done(reset_done)
    );
    onewire_write write (
        .clk(clk),
        .operation(operation),
        .enable(write_enable),
        .drive_low(write_drive_low),
        .done(write_done)
    );
    onewire_read read (
        .clk(clk),
        .enable(read_enable),
        .drive_low(read_drive_low),
        .sample(read_sample),
        .sample_idx(data_out_idx),
        .done(read_done)
    );
endmodule