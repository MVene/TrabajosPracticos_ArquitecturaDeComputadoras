`timescale 1ns / 1ps

module alu_tb;
    parameter DATA_WIDTH = 8;
    reg  [DATA_WIDTH-1:0] A, B;
    reg  [5:0] Op;
    wire [DATA_WIDTH-1:0] Result;

    alu #(DATA_WIDTH) uut (
        .A(A),
        .B(B),
        .Op(Op),
        .Result(Result)
    );

    reg [DATA_WIDTH-1:0] expected;
    integer i;

    initial begin
        $display("Inicio de prueba con entradas aleatorias...");
        for (i = 0; i < 20; i = i + 1) begin  // 20 pruebas aleatorias
            A  = $random;
            B  = $random;

            // Seleccionar operación aleatoria de las válidas
            case ($urandom_range(0,7))
                0: Op = 6'b100000; // ADD
                1: Op = 6'b100010; // SUB
                2: Op = 6'b100100; // AND
                3: Op = 6'b100101; // OR
                4: Op = 6'b100110; // XOR
                5: Op = 6'b000011; // SRA
                6: Op = 6'b000010; // SRL
                7: Op = 6'b100111; // NOR
            endcase

            // Calcular resultado esperado
            case (Op)
                6'b100000: expected = A + B;
                6'b100010: expected = A - B;
                6'b100100: expected = A & B;
                6'b100101: expected = A | B;
                6'b100110: expected = A ^ B;
                6'b000011: expected = $signed(A) >>> 1;
                6'b000010: expected = A >> 1;
                6'b100111: expected = ~(A | B);
                default:   expected = 0;
            endcase

            #5; // Esperar un poco para que cambie el resultado

            if (Result !== expected)
                $display("❌ Error: Op=%b, A=%h, B=%h, Result=%h, Esperado=%h", Op, A, B, Result, expected);
            else
                $display("✅ OK: Op=%b, A=%h, B=%h, Result=%h", Op, A, B, Result);
            
            #5; // Tiempo entre pruebas
        end

        $display("Fin de simulación.");
        $finish;
    end
endmodule
