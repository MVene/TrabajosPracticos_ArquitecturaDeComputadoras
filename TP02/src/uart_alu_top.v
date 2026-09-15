`timescale 1ns / 1ps

module uart_alu_top (
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire       i_rx,
    output wire       o_tx,

    output wire [7:0] o_leds,
    output wire [2:0] o_flags
);

    parameter CLK_FREQ   = 100_000_000;
    parameter BAUD_RATE  = 9600;
    parameter DATA_WIDTH = 8;
    parameter OP_WIDTH   = 6;

    // =========================
    // BAUD GENERATOR
    // =========================

    wire tick;

    // =========================
    // UART RX
    // =========================

    wire                  rx_done;
    wire [DATA_WIDTH-1:0] rx_data;

    // =========================
    // UART TX
    // =========================

    wire                  tx_start;
    wire [DATA_WIDTH-1:0] tx_data;
    wire                  tx_done;

    // =========================
    // ALU
    // =========================

    wire [DATA_WIDTH-1:0] alu_a;
    wire [DATA_WIDTH-1:0] alu_b;
    wire [OP_WIDTH-1:0]   alu_opcode;

    wire [DATA_WIDTH-1:0] alu_result;

    wire alu_carry;
    wire alu_zero;
    wire alu_negative;

    // =========================
    // LEDs Y FLAGS
    // =========================

    reg [7:0] leds_reg;
    reg [2:0] flags_reg;

    assign o_leds  = leds_reg;
    assign o_flags = flags_reg;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            leds_reg  <= 8'b00000000;
            flags_reg <= 3'b000;
        end
        else begin
            leds_reg  <= alu_result;
            flags_reg <= {
                alu_carry,
                alu_zero,
                alu_negative
            };
        end
    end


    // =========================
    // BAUD GENERATOR
    // =========================

    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(16)
    ) baud_gen_inst (
        .i_clk   (i_clk),
        .i_rst   (i_rst),
        .o_tick  (tick)
    );


    // =========================
    // UART RECEIVER
    // =========================

    uart_rx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_rx_inst (
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_rx       (i_rx),
        .i_tick     (tick),
        .o_rx_done  (rx_done),
        .o_data_out (rx_data)
    );


    // =========================
    // UART TRANSMITTER
    // =========================

    uart_tx #(
        .DATA_BITS(DATA_WIDTH),
        .OVERSAMPLING(16)
    ) uart_tx_inst (
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_tx_start (tx_start),
        .i_data_in  (tx_data),
        .i_tick     (tick),
        .o_tx       (o_tx),
        .o_tx_done  (tx_done)
    );


    // =========================
    // ALU
    // =========================

    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) alu_inst (
        .i_a        (alu_a),
        .i_b        (alu_b),
        .i_op       (alu_opcode),

        .o_result   (alu_result),
        .o_negative (alu_negative),
        .o_zero     (alu_zero),
        .o_carry    (alu_carry)
    );


    // =========================
    // INTERFACE UART <-> ALU
    // =========================

    interface #(
        .N_DATA(DATA_WIDTH),
        .N_OP(OP_WIDTH)
    ) interface_inst (
        .i_clk          (i_clk),
        .i_rst          (i_rst),

        .i_rx_done      (rx_done),
        .i_rx_data      (rx_data),

        .o_tx_start     (tx_start),
        .o_tx_data      (tx_data),
        .i_tx_done      (tx_done),

        .o_alu_a        (alu_a),
        .o_alu_b        (alu_b),
        .o_alu_opcode   (alu_opcode),

        .i_alu_result   (alu_result),
        .i_alu_carry    (alu_carry),
        .i_alu_zero     (alu_zero),
        .i_alu_negative (alu_negative)
    );

endmodule