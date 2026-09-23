`timescale 1ns / 1ps

module uart_rx #(
    parameter DATA_BITS = 8,
    parameter OVERSAMPLING = 16
)(
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_rx,          // línea serie desde PC
    input  wire i_tick,        // tick 16x de baud_gen
    output reg  o_rx_done,
    output wire [DATA_BITS-1:0] o_data_out
);
    localparam [2:0] S_IDLE  = 0, 
                     S_START = 1, 
                     S_DATA  = 2, 
                     S_STOP  = 3;

    reg [1:0] current_state, next_state;
    reg [3:0] tick_count_reg, tick_count_next;                    // para llevar la cuenta de los ticks
    reg [$clog2(DATA_BITS)-1:0] bit_count_reg, bit_count_next;  // para llevar la cuenta de los bits recibidos
    reg [DATA_BITS-1:0] data_buffer_reg, data_buffer_next;          // para guardar los bits recibidos

    always @(posedge i_clk) begin  //guardar los valores nuevos en cada flanco de clock​
        if (i_rst) begin
            current_state <= S_IDLE;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
            data_buffer_reg <= 0;
        end else begin
            current_state <= next_state;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            data_buffer_reg <= data_buffer_next;
        end
    end
    
    // Lógica del próximo estado
    always @(*)
    begin
        next_state = current_state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        data_buffer_next = data_buffer_reg;
        o_rx_done = 1'b0;
        case (current_state)
            S_IDLE:
                if (~i_rx) 
                begin
                    tick_count_next = 0;
                    next_state = S_START;
                end
            S_START:
                if (i_tick) begin
                    if (tick_count_reg == (OVERSAMPLING/2 - 1)) begin    // Cuando llega a 7 reseteamos los ticks a 0 para poder leer a la mitad de los bits a los 16 ticks
                    
                        if (~i_rx) begin // Si sigue en 0, es un start válido
                        
                            tick_count_next = 0;
                            bit_count_next = 0;
                            next_state = S_DATA;
                        end
                        else begin
                            // Volvió a 1: falso Start
                            tick_count_next = 0;
                            bit_count_next = 0;
                            next_state = S_IDLE;
                        end
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            S_DATA:
                if (i_tick)
                    if (tick_count_reg == (OVERSAMPLING - 1))     // Nos encontramos en la mitad del bit
                    begin
                        tick_count_next = 0; // Reiniciamos los ticks
                        data_buffer_next = {i_rx, data_buffer_reg[DATA_BITS-1:1]};   // Shift a la derecha
                        if (bit_count_reg == (DATA_BITS-1))
                            next_state = S_STOP;    // Si ya leimos el ultimo bit, paramos
                        else
                            bit_count_next = bit_count_reg + 1;     // Continuamos para leer el próximo bit
                    end
                    else
                        tick_count_next = tick_count_reg + 1;
            S_STOP:
                if (i_tick)
                    if (tick_count_reg == (OVERSAMPLING - 1))
                    begin
                        o_rx_done = 1'b1;
                        next_state = S_IDLE;
                    end
                    else
                        tick_count_next = tick_count_reg + 1;
            default:
                next_state = S_IDLE;
        endcase
    end
    
    // Logica de salida
    assign o_data_out = data_buffer_reg;
endmodule