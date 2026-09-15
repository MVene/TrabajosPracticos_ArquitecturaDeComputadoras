`timescale 1ns / 1ps
module uart_tx #(
    parameter DATA_BITS = 8,
    parameter OVERSAMPLING = 16
)(
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_tx_start,                   // Señal para iniciar la transmisión
    input  wire [DATA_BITS-1:0] i_data_in,    // Datos a transmitir
    input  wire i_tick,                       // Tick 16x de baud_gen
    output reg o_tx,                          // Línea serie de salida
    output reg o_tx_done                      // Señal de finalización de transmisión
);
    localparam [2:0] S_IDLE  = 0, 
                     S_START = 1, 
                     S_DATA  = 2, 
                     S_STOP  = 3;

    reg [1:0] current_state, next_state;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [$clog2(DATA_BITS)-1:0] bit_count_reg, bit_count_next;
    reg [DATA_BITS-1:0] data_reg;   // Registro para capturar data_in
    reg tx_next;                    // Señal para el próximo valor de tx

    always @(posedge i_clk) begin
        if (i_rst) begin
            current_state <= S_IDLE;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
            o_tx <= 1; // Línea inactiva (alto)
            o_tx_done <= 1'b0;
            data_reg <= 0;
        end else begin
            current_state <= next_state;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            o_tx <= tx_next;
            
            // Capturar datos cuando se inicia transmisión
            if (current_state == S_IDLE && i_tx_start)
                data_reg <= i_data_in;

            // Generar tx_done de forma síncrona (1 ciclo) cuando se completa el STOP
            if (current_state == S_STOP && i_tick && (tick_count_reg == (OVERSAMPLING - 1)))
                o_tx_done <= 1'b1;
            else
                o_tx_done <= 1'b0;
        end
    end
    
    // Lógica del próximo estado
    always @(*) begin
        next_state = current_state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        // o_tx_done = 1'b0;  // o_tx_done ahora es síncrono
        tx_next = o_tx; // Mantener valor actual por defecto
        
        case (current_state)
            S_IDLE: begin
                tx_next = 1; // Línea en alto
                if (i_tx_start) begin
                    tick_count_next = 0;
                    bit_count_next = 0;
                    next_state = S_START;
                    tx_next = 0;    // Bit de inicio (bajo)
                end
            end
            
            S_START: begin
                tx_next = 0;    // Mantenemos bit de inicio
                if (i_tick) begin
                    if (tick_count_reg == (OVERSAMPLING - 1)) begin
                        tick_count_next = 0;
                        next_state = S_DATA;
                        tx_next = data_reg[0];  // Primer bit de datos
                    end else
                        tick_count_next = tick_count_reg + 1;
                end
            end
            
            S_DATA: begin
                tx_next = data_reg[bit_count_reg];  // Mantenemos bit actual
                if (i_tick) begin
                    if (tick_count_reg == (OVERSAMPLING - 1)) begin
                        tick_count_next = 0;
                        if (bit_count_reg == (DATA_BITS - 1)) begin
                            next_state = S_STOP;
                            tx_next = 1; // Bit de parada
                        end else begin
                            bit_count_next = bit_count_reg + 1;
                            tx_next = data_reg[bit_count_reg + 1];  // Siguiente bit
                        end
                    end else
                        tick_count_next = tick_count_reg + 1;
                end
            end
            
            S_STOP: begin
                tx_next = 1;    // Bit de parada (alto)
                if (i_tick) begin
                    if (tick_count_reg == (OVERSAMPLING - 1)) begin
                        // tx_done se genera en el flanco de reloj para que la FSM lo detecte
                        next_state = S_IDLE;
                    end else
                        tick_count_next = tick_count_reg + 1;
                end
            end
            
            default: begin
                next_state = S_IDLE;
                tx_next = 1;
            end
        endcase
    end
endmodule