`timescale 1ns / 1ps

module alu_top_tb;

    // Parámetros
    localparam DATA_WIDTH = 8;
    localparam BTN_COUNT  = 4;
    localparam OP_WIDTH   = 6;

    // Entradas
    reg i_clk;
    reg [DATA_WIDTH-1:0] i_sw;
    reg [BTN_COUNT-1:0]  i_btn;

    // Salidas
    wire [DATA_WIDTH-1:0] o_led;

    // Instancia del módulo bajo prueba (UUT)
    alu_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .BTN_COUNT(BTN_COUNT),
        .OP_WIDTH(OP_WIDTH)
    ) uut (
        .i_clk(i_clk),
        .i_sw(i_sw),
        .i_btn(i_btn),
        .o_led(o_led)
    );

    // Generador de clock (100 MHz → periodo 10 ns)
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

    // Proceso de estímulo
    initial begin
        // Inicialización
        i_sw  = 0;
        i_btn = 0;

        $display("=== INICIO DE SIMULACION ===");

        // Reset general
        #10;
        i_btn[3] = 1;  // en_rst
        #10;
        i_btn[3] = 0;

        // Cargar A = 8'd15 = 00001111
        i_sw  = 8'd15;
        i_btn[0] = 1;  // en_A
        #10;
        i_btn[0] = 0;

        // Cargar B = 8'd5 = 00000101
        i_sw  = 8'd5;
        i_btn[1] = 1;  // en_B
        #10;
        i_btn[1] = 0;

        // Seleccionar operación ADD (100000)
        i_sw  = 8'b00100000;  // 6'b100000 = ADD
        i_btn[2] = 1;         // en_Op
        #10;
        i_btn[2] = 0;

        // Esperar un poco y mostrar resultado
        #10;
        $display("ADD:  A=%d, B=%d -> Result=%d (LED=%b)", 15, 5, o_led, o_led);

        // Seleccionar operación SUB (100010)
        i_sw  = 8'b00100010;  // 6'b100010 = SUB
        i_btn[2] = 1;
        #10;
        i_btn[2] = 0;

        // Esperar y mostrar resultado
        #10;
        $display("SUB:  A=%d, B=%d -> Result=%d (LED=%b)", 15, 5, o_led, o_led);

        // Probar reset otra vez
        i_btn[3] = 1;
        #10;
        i_btn[3] = 0;

        // Fin de simulación
        #20;
        $display("=== FIN DE SIMULACION ===");
        $finish;
    end

endmodule
