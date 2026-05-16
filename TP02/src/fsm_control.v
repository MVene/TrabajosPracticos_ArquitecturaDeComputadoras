//máquina de estados del TP2.: espera datos de UART RX, los interpreta, activa la ALU y luego dispara la transmisión por UART TX.
module fsm_control (
    input clk, rst,
    input rx_ready,
    input [7:0] rx_data,
    output reg alu_start,
    output reg tx_start,
    output reg [2:0] alu_op,
    output reg [7:0] operand_a,
    output reg [7:0] operand_b
);

    // Definición de estados
    typedef enum reg [1:0] {
        IDLE     = 2'b00,
        RECEIVE  = 2'b01,
        EXECUTE  = 2'b10,
        SEND     = 2'b11
    } state_t;

    state_t state, next_state;

    // Registro de estado
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Lógica de transición
    always @(*) begin
        alu_start = 0;
        tx_start  = 0;
        next_state = state;

        case (state)
            IDLE: begin
                if (rx_ready)
                    next_state = RECEIVE;
            end

            RECEIVE: begin
                // Ejemplo: primer byte = operación, segundo y tercero = operandos
                alu_op    = rx_data[2:0];
                operand_a = 8'h05; // placeholder
                operand_b = 8'h03; // placeholder
                next_state = EXECUTE;
            end

            EXECUTE: begin
                alu_start = 1;
                next_state = SEND;
            end

            SEND: begin
                tx_start = 1;
                next_state = IDLE;
            end
        endcase
    end

endmodule
