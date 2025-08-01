`include "onewire_write.v"
`include "onewire_read.v"
`include "onewire_reset.v"

module onewire_master (
    input wire clk, // 27 MHz clock, 1us = 27 clock cycles
    input wire rst_n, // Acts as a start signal, active low
    inout wire onewire
);
    // Each running state is handled by a separate module
    // TODO: remove state and use enable signals as state in FSM
    localparam IDLE = 2'b00;
    localparam RESET = 2'b01;
    localparam WRITE = 2'b10;
    localparam READ = 2'b11;
    reg [1:0] state = IDLE;

    // Control signals for the individual modules
    reg reset_enable, write_enable, read_enable;
    wire reset_drive_low, write_drive_low, read_drive_low;
    wire write_done, read_done, reset_done;
    wire reset_sample, read_sample;

    reg device_present; // TODO: Do something with if device not precent
    
    // idx will always be <8. It is 4 bits wide because that makes the read module easier.
    reg [7:0] data_out; 
    wire [3:0] data_out_idx;

    // Drives the onewire low or releases it based on the current state
    wire drive_low;
    assign drive_low = (reset_enable & reset_drive_low) | (read_enable & read_drive_low) | (write_enable & write_drive_low); // max one of the enables will be high at any given time
    assign onewire = drive_low ? 1'b0 : 1'bz; 


    // FSM from IDLE -> RESET -> WRITE -> READ -> IDLE 
    // The process is started when rst_n is low, and keep running until back to IDLE, i.e it cannot be stopped once running
    // Individual modules reset their done variable when enable is low
    always @(posedge clk) begin
        case (state) 
            IDLE: begin
                if (!rst_n) begin
                    state <= RESET;
                    reset_enable <= 1'b1;
                end
            end
            RESET: begin
                if (reset_done) begin
                    state <= WRITE;
                    reset_enable <= 1'b0;
                    write_enable <= 1'b1;
                end else if (reset_sample) begin
                    device_present <= (onewire == 1'b0);
                end
            end
            WRITE: begin
                if (write_done) begin
                    state <= READ;
                    write_enable <= 1'b0;
                    read_enable <= 1'b1;
                end
            end
            READ: begin
                if (read_done) begin
                    state <= IDLE;
                    read_enable <= 0;
                end else if (read_sample) begin
                    data_out[data_out_idx] <= onewire;
                end
            end
        endcase
    end

    wire [7:0] operation;
    
    onewire_write write(
        .clk(clk), 
        .operation(operation), 
        .enable(write_enable), 
        .drive_low(write_drive_low),
        .done(write_done)
    );
    onewire_read read(
        .clk(clk),
        .enable(read_enable),
        .drive_low(read_drive_low),
        .sample(read_sample),
        .done(read_done),
        .sample_idx(data_out_idx)
    );
    onewire_reset reset (
        .clk(clk),
        .enable(reset_enable),
        .drive_low(reset_drive_low),
        .sample(reset_sample),
        .done(reset_done)
    );
    
endmodule