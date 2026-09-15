`timescale 1ns / 1ps

module interface #(
    parameter N_DATA = 8,       // ancho de datos
    parameter N_OP = 6          // ancho de código de operación
)(
    input wire i_clk,
    input wire i_rst,
    // interfaz UART RX
    input wire i_rx_done,
    input wire [N_DATA-1:0] i_rx_data,
    // interfaz UART TX
    output reg o_tx_start,
    output reg [N_DATA-1:0] o_tx_data,
    input wire i_tx_done,
    // interfaz ALU
    output reg [N_DATA-1:0] o_alu_a,
    output reg [N_DATA-1:0] o_alu_b,
    output reg [N_OP-1:0] o_alu_opcode,
    input wire [N_DATA-1:0] i_alu_result,
    input wire i_alu_carry,
    input wire i_alu_zero,
    input wire i_alu_negative

);

    // Estados de la FSM
    localparam [2:0] 
        S_GET_A = 0,
        S_GET_B = 1,
        S_GET_OP = 2,
        S_SEND_RESULT = 3,
        S_WAIT_RESULT = 4,
        S_SEND_FLAGS = 5,
        S_WAIT_FLAGS = 6;
    
    reg [2:0] state;
    
    always @(posedge i_clk) begin
        if (i_rst) begin
            state <= S_GET_A;
            o_tx_start <= 1'b0;
            o_tx_data <= {N_DATA{1'b0}};
            o_alu_a <= {N_DATA{1'b0}};
            o_alu_b <= {N_DATA{1'b0}};
            o_alu_opcode <= {N_OP{1'b0}};
        end else begin
            // tx_start se va a activar solo durante un ciclo
            o_tx_start <= 1'b0;
            
            case (state)
                S_GET_A: begin
                    if (i_rx_done) begin
                        o_alu_a <= i_rx_data;
                        state <= S_GET_B;
                    end
                end
                
                S_GET_B: begin
                    if (i_rx_done) begin
                        o_alu_b <= i_rx_data;
                        state <= S_GET_OP;
                    end
                end
                
                S_GET_OP: begin
                    if (i_rx_done) begin
                        o_alu_opcode <= i_rx_data[N_OP-1:0];
                        // Como la ALU es combinacional, pasamos directamente al estado para mandar el resultado
                        state <= S_SEND_RESULT;
                    end
                end
                
                S_SEND_RESULT: begin
                    o_tx_data <= i_alu_result;
                    o_tx_start <= 1'b1;
                    state <= S_WAIT_RESULT;
                end
                
                S_WAIT_RESULT: begin
                    if (i_tx_done) begin
                        state <= S_SEND_FLAGS;
                    end
                end
                
                S_SEND_FLAGS: begin
                    o_tx_data <= {{(N_DATA-3){1'b0}}, i_alu_carry, i_alu_zero, i_alu_negative};
                    o_tx_start <= 1'b1;
                    state <= S_WAIT_FLAGS;
                end
                
                S_WAIT_FLAGS: begin
                    if (i_tx_done) begin
                        state <= S_GET_A;
                    end
                end
                
                default:
                    state <= S_GET_A;
            endcase
        end
    end

endmodule