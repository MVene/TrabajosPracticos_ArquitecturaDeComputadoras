`timescale 1ns / 1ps

module uart_alu_top (
    input wire clk,
    input wire rst,
    input wire rx,
    output wire tx,

    output wire [7:0] leds,
    output wire [2:0] flags
);

    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 9600;
    parameter DATA_WIDTH = 8;
    parameter OP_WIDTH = 6;

    wire tick;
    wire rx_done;
    wire [DATA_WIDTH-1:0] rx_data;

    wire tx_start;
    wire [DATA_WIDTH-1:0] tx_data;
    wire tx_done;

    wire [DATA_WIDTH-1:0] alu_a;
    wire [DATA_WIDTH-1:0] alu_b;
    wire [OP_WIDTH-1:0] alu_opcode;
    wire [DATA_WIDTH-1:0] alu_result;

    wire alu_carry;
    wire alu_zero;
    wire alu_negative;

    reg [7:0] leds_reg;
    reg [2:0] flags_reg;

    assign leds = leds_reg;
    assign flags = flags_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds_reg <= 8'b00000000;
            flags_reg <= 3'b000;
        end else begin
            leds_reg <= alu_result;
            flags_reg <= {alu_carry, alu_zero, alu_negative};
        end
    end

    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(16)
    ) baud_gen_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    uart_rx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tick(tick),
        .rx_done(rx_done),
        .data_out(rx_data)
    );

    uart_tx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tick(tick),
        .tx(tx),
        .tx_done(tx_done)
    );

    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) alu_inst (
        .i_a(alu_a),
        .i_b(alu_b),
        .i_op(alu_opcode),
        .o_result(alu_result),
        .o_negative(alu_negative),
        .o_zero(alu_zero),
        .o_carry(alu_carry)
    );

    interface #(
        .N_DATA(DATA_WIDTH),
        .N_OP(OP_WIDTH)
    ) interface_inst (
        .clk(clk),
        .rst(rst),

        .rx_done(rx_done),
        .rx_data(rx_data),

        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),

        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_opcode(alu_opcode),
        .alu_result(alu_result),
        .alu_carry(alu_carry),
        .alu_zero(alu_zero),
        .alu_negative(alu_negative)
    );

endmodule