`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,   // Frecuencia del clock de la Basys 3 (100 MHz)
    parameter BAUD_RATE = 9600          // Velocidad de transmisión UART
)(
    input clk,
    input rst,
    input rx,                           // Entrada serial desde PC
    output reg [7:0] rx_data,           // Byte recibido
    output reg rx_ready                 // Flag: dato válido
);

    localparam TICKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] tick_count = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] shift_reg = 0;
    reg receiving = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tick_count <= 0;
            bit_index  <= 0;
            receiving  <= 0;
            rx_ready   <= 0;
        end else begin
            if (!receiving) begin
                // Detecta bit de start (rx = 0)
                if (rx == 0) begin
                    receiving  <= 1;
                    tick_count <= TICKS_PER_BIT/2; // muestreo en mitad del bit
                    bit_index  <= 0;
                end
            end else begin
                if (tick_count == TICKS_PER_BIT-1) begin
                    tick_count <= 0;
                    shift_reg[bit_index] <= rx;
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        receiving <= 0;
                        rx_data   <= shift_reg[8:1]; // bits de datos
                        rx_ready  <= 1;
                    end
                end else begin
                    tick_count <= tick_count + 1;
                end
            end
        end
    end
endmodule
