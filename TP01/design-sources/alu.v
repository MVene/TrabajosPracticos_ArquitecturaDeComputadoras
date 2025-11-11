`timescale 1ns / 1ps

module alu #(
    parameter DATA_WIDTH = 8,
    parameter OP_WIDTH = 6
)(
    input  [DATA_WIDTH-1:0] i_a,
    input  [DATA_WIDTH-1:0] i_b,
    input  [OP_WIDTH-1:0] i_op,
    output reg [DATA_WIDTH-1:0] o_result,
    output reg o_negative,
    output reg o_zero,
    output reg o_carry
);

    // Cantidad de bits necesarios para representar DATA_WIDTH-1
    // Ej: si DATA_WIDTH=8 → SHIFT_WIDTH=3, si DATA_WIDTH=16 → SHIFT_WIDTH=4
    localparam SHIFT_WIDTH = $clog2(DATA_WIDTH);

    reg [DATA_WIDTH:0] temp; // un bit más para carry

    always @(*) begin
        o_result   = 0;
        o_negative = 0;
        o_zero     = 0;
        o_carry    = 0;

        case (i_op)
            6'b100000: begin
                temp = {1'b0, i_a} + {1'b0, i_b}; //AND
                o_result = temp[DATA_WIDTH-1:0]; 
                o_carry  = temp[DATA_WIDTH];   // carry out            // ADD
            end
            
            6'b100010:  begin // SUB
                temp = {1'b0, i_a} - {1'b0, i_b};
                o_result = temp[DATA_WIDTH-1:0];
                o_carry  = ~temp[DATA_WIDTH];  // carry clear on borrow
            end

            6'b100100: o_result = i_a & i_b;            // AND
            6'b100101: o_result = i_a | i_b;            // OR
            6'b100110: o_result = i_a ^ i_b;            // XOR
            6'b000011: o_result = $signed(i_a) >>> i_b[SHIFT_WIDTH-1:0];  // SRA
            6'b000010: o_result = i_a >> i_b[SHIFT_WIDTH-1:0];            // SRL
            6'b100111: o_result = ~(i_a | i_b);         // NOR
            default:   o_result = {DATA_WIDTH{1'b0}};
        endcase

        // flags comunes
        o_zero     = (o_result == 0);
        o_negative = o_result[DATA_WIDTH-1];

    end
endmodule
