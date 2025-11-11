`timescale 1ns / 1ps

module alu_top_tb;

    // ------------------------------------------------------
    // Parámetros
    // ------------------------------------------------------
    localparam DATA_WIDTH = 8;
    localparam BTN_COUNT  = 4;
    localparam OP_WIDTH   = 6;

    // ------------------------------------------------------
    // Entradas
    // ------------------------------------------------------
    reg i_clk;
    reg [DATA_WIDTH-1:0] i_sw;
    reg [BTN_COUNT-1:0]  i_btn;

    // ------------------------------------------------------
    // Salidas
    // ------------------------------------------------------
    wire [DATA_WIDTH-1:0] o_led;
    wire [2:0]            o_flags; // {negative, zero, overflow}

    // ------------------------------------------------------
    // Instancia del módulo bajo prueba (UUT)
    // ------------------------------------------------------
    alu_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .BTN_COUNT(BTN_COUNT),
        .OP_WIDTH(OP_WIDTH)
    ) uut (
        .i_clk(i_clk),
        .i_sw(i_sw),
        .i_btn(i_btn),
        .o_led(o_led),
        .o_flags(o_flags)
    );

    // ------------------------------------------------------
    // Clock 100 MHz (10 ns periodo)
    // ------------------------------------------------------
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

    // ------------------------------------------------------
    // Tarea para cargar A, B y operación
    // ------------------------------------------------------
    task load_values(input [7:0] A, input [7:0] B, input [5:0] OP);
    begin
        // Cargar A
        i_sw = A;
        i_btn[0] = 1; #10; i_btn[0] = 0;

        // Cargar B
        i_sw = B;
        i_btn[1] = 1; #10; i_btn[1] = 0;

        // Cargar operación
        i_sw = {2'b00, OP}; // los 6 bits menos significativos son la operación
        i_btn[2] = 1; #10; i_btn[2] = 0;

        #10; // esperar resultado estable
    end
    endtask

    // ------------------------------------------------------
    // Estímulos
    // ------------------------------------------------------
    initial begin
        $display("===== INICIO DE SIMULACIÓN ALU =====");

        // Inicialización
        i_sw  = 0;
        i_btn = 0;
        #10;

        // Reset
        i_btn[3] = 1; #10; i_btn[3] = 0;

        // ================== Pruebas ==================

        // Caso 1: ADD normal
        load_values(8'd15, 8'd5, 6'b100000);
        $display("ADD:  15 + 5  = %d  | Result=%b | Flags (N,Z,O)=%b", o_led, o_led, o_flags);

        // Caso 2: SUB con resultado negativo
        load_values(8'd5, 8'd15, 6'b100010);
        $display("SUB:  5 - 15 = %d  | Result=%b | Flags (N,Z,O)=%b", $signed(o_led), o_led, o_flags);

        // Caso 3: Overflow (255 + 1)
        load_values(8'd255, 8'd1, 6'b100000);
        $display("ADD Overflow: 255 + 1 = %d | Result=%b | Flags (N,Z,O)=%b", $signed(o_led), o_led, o_flags);

        // Caso 4: AND
        load_values(8'b10101010, 8'b11001100, 6'b100100);
        $display("AND:  10101010 & 11001100 = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 5: OR
        load_values(8'b10101010, 8'b01010101, 6'b100101);
        $display("OR:   10101010 | 01010101 = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 6: XOR
        load_values(8'b11110000, 8'b10101010, 6'b100110);
        $display("XOR:  11110000 ^ 10101010 = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 7: NOR
        load_values(8'b11110000, 8'b00001111, 6'b100111);
        $display("NOR: ~(11110000 | 00001111) = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 8: Shift Right Lógico (SRL)
        load_values(8'b10100000, 8'd2, 6'b000010);
        $display("SRL: 10100000 >> 2 = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 9: Shift Right Aritmético (SRA)
        load_values(8'b10100000, 8'd2, 6'b000011);
        $display("SRA: 10100000 >>> 2 = %b | Flags (N,Z,O)=%b", o_led, o_flags);

        // Caso 10: Resultado cero
        load_values(8'd5, 8'd5, 6'b100010);
        $display("SUB:  5 - 5 = %d  | Result=%b | Flags (N,Z,O)=%b", o_led, o_led, o_flags);

        #10;
        // Reset
        i_btn[3] = 1; #10; i_btn[3] = 0;
        
        // ================== Fin ==================
        #20;
        $display("===== FIN DE SIMULACIÓN =====");
        $finish;
    end

endmodule
