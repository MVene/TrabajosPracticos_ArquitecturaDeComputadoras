`timescale 1ns / 1ps

// ====== OPCODES ======
`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define XOR 6'b100110
`define SRA 6'b000011
`define SRL 6'b000010
`define NOR 6'b100111

module alu_tb;

    // ====== Parámetros ======
    localparam DATA_WIDTH = 8;
    localparam OP_WIDTH   = 6;
    localparam NUM_TESTS  = 50;  // número de pruebas aleatorias

    // ====== Señales del DUT ======
    reg  [DATA_WIDTH-1:0] i_a, i_b;
    reg  [OP_WIDTH-1:0]   i_op;
    wire [DATA_WIDTH-1:0] o_result;
    wire o_negative, o_zero, o_carry;

    // ====== Instancia de la ALU ======
    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) dut (
        .i_a(i_a),
        .i_b(i_b),
        .i_op(i_op),
        .o_result(o_result),
        .o_negative(o_negative),
        .o_zero(o_zero),
        .o_carry(o_carry)
    );

    // ====== Modelo de referencia ======
    function [DATA_WIDTH-1:0] model_result;
        input [DATA_WIDTH-1:0] a, b;
        input [OP_WIDTH-1:0] op;
        reg signed [DATA_WIDTH-1:0] sa;
        begin
            sa = a;
            case (op)
                `ADD: model_result = a + b;
                `SUB: model_result = a - b;
                `AND: model_result = a & b;
                `OR:  model_result = a | b;
                `XOR: model_result = a ^ b;
                `SRA: model_result = sa >>> b[$clog2(DATA_WIDTH)-1:0];
                `SRL: model_result = a >> b[$clog2(DATA_WIDTH)-1:0];
                `NOR: model_result = ~(a | b);
                default: model_result = 0;
            endcase
        end
    endfunction

    // ====== Flags de referencia ======
    function automatic reg model_zero;
        input [DATA_WIDTH-1:0] res;
        begin
            model_zero = (res == 0);
        end
    endfunction

    function automatic reg model_negative;
        input [DATA_WIDTH-1:0] res;
        input [OP_WIDTH-1:0] op;
        begin
            model_negative = res[DATA_WIDTH-1] && (op == `SUB || op == `SRA);
        end
    endfunction

    function automatic reg model_carry;
        input [DATA_WIDTH-1:0] a, b;
        input [OP_WIDTH-1:0] op;
        reg [DATA_WIDTH:0] temp;
        begin
            temp = {1'b0, a} + {1'b0, b};
            if (op == `ADD)
                model_carry = temp[DATA_WIDTH];
            else
                model_carry = 1'b0;
        end
    endfunction

    // ====== Control de test ======
    integer i, op_sel, errors = 0;
    reg [DATA_WIDTH-1:0] expected_result;
    reg exp_z, exp_n, exp_c;

    // ====== Test principal ======
    initial begin
        $display("===================================================");
        $display("🧮 INICIO DE VALIDACIÓN AUTOMÁTICA ALU (%0d bits)", DATA_WIDTH);
        $display("===================================================\n");

        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // Generación aleatoria
            i_a = $urandom();
            i_b = $urandom();
            op_sel = $urandom_range(0, 7);
            case (op_sel)
                0: i_op = `ADD;
                1: i_op = `SUB;
                2: i_op = `AND;
                3: i_op = `OR;
                4: i_op = `XOR;
                5: i_op = `SRA;
                6: i_op = `SRL;
                7: i_op = `NOR;
            endcase

            #1; // Esperar propagación

            // Modelo de referencia
            expected_result = model_result(i_a, i_b, i_op);
            exp_z = model_zero(expected_result);
            exp_n = model_negative(expected_result, i_op);
            exp_c = model_carry(i_a, i_b, i_op);

            // Comparación
            if (o_result !== expected_result ||
                o_zero !== exp_z ||
                o_negative !== exp_n ||
                o_carry !== exp_c) begin

                $display(" ERROR #%0d | Op=%b | A=%0d | B=%0d", i, i_op, i_a, i_b);
                $display("   Esperado: Res=%0d Z=%b N=%b C=%b", expected_result, exp_z, exp_n, exp_c);
                $display("   Obtenido: Res=%0d Z=%b N=%b C=%b\n", o_result, o_zero, o_negative, o_carry);
                errors = errors + 1;
            end
            else begin
                $display(" OK #%0d | Op=%b | A=%0d | B=%0d | Res=%0d | N=%b Z=%b C=%b",
                         i, i_op, i_a, i_b, o_result, o_negative, o_zero, o_carry);
            end

            #4;
        end

        $display("\n===================================================");
        if (errors == 0)
            $display(" TODAS LAS %0d PRUEBAS PASARON EXITOSAMENTE", NUM_TESTS);
        else
            $display(" SE DETECTARON %0d ERRORES EN %0d PRUEBAS", errors, NUM_TESTS);
        $display("===================================================\n");

        $finish;
    end

endmodule
