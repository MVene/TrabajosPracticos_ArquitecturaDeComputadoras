`timescale 1ns / 1ps

`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define XOR 6'b100110
`define SRA 6'b000011
`define SRL 6'b000010
`define NOR 6'b100111

module alu #(
    parameter DATA_WIDTH = 8,
    parameter OP_WIDTH = 6
)(
    input  [DATA_WIDTH-1:0] i_a,
    input  [DATA_WIDTH-1:0] i_b,
    input  [OP_WIDTH-1:0] i_op,
    output reg [DATA_WIDTH-1:0] o_result,
    output reg o_negative, o_zero, o_carry
);

    // Cantidad de bits necesarios para representar DATA_WIDTH-1
    // Ej: si DATA_WIDTH=8 → SHIFT_WIDTH=3, si DATA_WIDTH=16 → SHIFT_WIDTH=4
    localparam SHIFT_WIDTH = $clog2(DATA_WIDTH);

    always @(*) begin
        o_result   = 0;
        o_negative = 0;
        o_zero     = 0;
        o_carry    = 0;

        case (i_op)
            `ADD: {o_carry, o_result} = {1'b0, i_a} + {1'b0, i_b};                   // ADD
            `SUB: o_result = {1'b0, i_a} - {1'b0, i_b};                                 // SUB
            `AND: o_result = i_a & i_b;                                                 // AND
            `OR:  o_result = i_a | i_b;                                                 // OR
            `XOR: o_result = i_a ^ i_b;                                                 // XOR
            `SRA: o_result = $signed(i_a) >>> i_b[SHIFT_WIDTH-1:0];                     // SRA
            `SRL: o_result = i_a >> i_b[SHIFT_WIDTH-1:0];                               // SRL
            `NOR: o_result = ~(i_a | i_b);                                              // NOR
            default:   o_result = {DATA_WIDTH{1'b0}};
        endcase

        // flags comunes
        o_zero     = (o_result == 0);
        o_negative = o_result[DATA_WIDTH-1] && (i_op == `SUB || i_op == `SRA);

    end
endmodule
