`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQ = 100_000_000,   // Clock Basys 3 = 100 MHz
    parameter BAUD_RATE = 9600          // Velocidad UART
)(
    input clk,
    input rst,
    input [7:0] tx_data,                // Byte a enviar
    input tx_start,                     // Señal de inicio de transmisión
    output reg tx,                      // Línea serial hacia PC
    output reg tx_busy                  // Flag: transmisión en curso
);

    localparam TICKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] tick_count = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] shift_reg = 10'b1111111111; // stop bits por defecto

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx        <= 1; // línea en reposo = alto
            tx_busy   <= 0;
            tick_count <= 0;
            bit_index  <= 0;
        end else begin
            if (!tx_busy) begin
                if (tx_start) begin
                    // Arma trama: start(0) + datos + stop(1)
                    shift_reg <= {1'b1, tx_data, 1'b0};
                    tx_busy   <= 1;
                    bit_index <= 0;
                    tick_count <= 0;
                end
            end else begin
                if (tick_count == TICKS_PER_BIT-1) begin
                    tick_count <= 0;
                    tx <= shift_reg[bit_index];
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        tx_busy <= 0; // transmisión terminada
                        tx <= 1;      // línea vuelve a reposo
                    end
                end else begin
                    tick_count <= tick_count + 1;
                end
            end
        end
    end
endmodule
