`timescale 1ns / 1ps

module tb_uart_alu_top;

    // =====================================================
    // PARÁMETROS DE SIMULACIÓN
    // =====================================================

    // Valores acelerados para simulación.
    // 20 MHz / (625000 * 16) = 2 clocks por tick.

    localparam integer CLK_FREQ_TB  = 20_000_000;
    localparam integer BAUD_RATE_TB = 625_000;

    // Clock de 20 MHz -> período = 50 ns
    localparam integer CLK_PERIOD = 50;

    // 625000 baud -> período de bit = 1600 ns
    localparam integer BIT_PERIOD = 1600;


    // =====================================================
    // SEÑALES
    // =====================================================

    reg i_clk;
    reg i_rst;
    reg i_rx;

    wire o_tx;
    wire [7:0] o_leds;
    wire [2:0] o_flags;

    reg signed [7:0] resultado_recibido;
    reg [7:0] flags_recibidos;


    // =====================================================
    // DUT
    // =====================================================

    uart_alu_top #(
        .CLK_FREQ(CLK_FREQ_TB),
        .BAUD_RATE(BAUD_RATE_TB),
        .DATA_WIDTH(8),
        .OP_WIDTH(6)
    ) DUT (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rx(i_rx),
        .o_tx(o_tx),
        .o_leds(o_leds),
        .o_flags(o_flags)
    );


    // =====================================================
    // CLOCK
    // =====================================================

    initial begin
        i_clk = 0;
    end

    always begin
        #(CLK_PERIOD/2);
        i_clk = ~i_clk;
    end


    // =====================================================
    // TASK: ENVIAR BYTE UART
    // =====================================================

    task uart_send_byte;

        input [7:0] dato;
        integer i;

        begin

            // START
            i_rx = 0;
            #(BIT_PERIOD);

            // D0 a D7
            for (i = 0; i < 8; i = i + 1) begin
                i_rx = dato[i];
                #(BIT_PERIOD);
            end

            // STOP
            i_rx = 1;
            #(BIT_PERIOD);

        end

    endtask


    // =====================================================
    // TASK: RECIBIR BYTE UART
    // =====================================================

    task uart_receive_byte;

        output [7:0] dato;
        integer i;

        begin

            // Esperar START
            @(negedge o_tx);

            // Ir al centro de D0
            #(BIT_PERIOD + BIT_PERIOD/2);

            // Leer D0 ... D7
            for (i = 0; i < 8; i = i + 1) begin
                dato[i] = o_tx;
                #(BIT_PERIOD);
            end

            // Verificar STOP
            if (o_tx !== 1'b1)
                $display("ERROR: STOP incorrecto");

        end

    endtask


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        // UART en reposo
        i_rx = 1;

        // Reset
        i_rst = 1;

        repeat (5)
            @(posedge i_clk);

        @(negedge i_clk);
        i_rst = 0;

        #(BIT_PERIOD);


        $display("-----------------------------");
        $display("TEST: 170 - 229");
        $display("-----------------------------");


        fork

            // Simula lo que hace Python:
            // manda A, B y OP
            begin

                uart_send_byte(8'b10101010);  // A = 170
                uart_send_byte(8'b11100101);  // B = 229
                uart_send_byte(8'h22);        // SUB

            end


            // Esperar respuesta de la FPGA
            begin

                uart_receive_byte(resultado_recibido);
                uart_receive_byte(flags_recibidos);

            end

        join




        $display("Resultado = %b (Decimal: %d)", resultado_recibido, resultado_recibido);
        $display("Flags     = %b", flags_recibidos);
        $display("LEDs      = %b", o_leds);
        $display("Flags top = %b", o_flags);




        // 170 - 229 = -59 = 197 (11000101)
        if (resultado_recibido == 8'b11000101)
            $display("RESULTADO CORRECTO");
        else
            $display("ERROR EN RESULTADO");


        // Negative = 1
        if (flags_recibidos == 8'b00000001)
            $display("FLAGS CORRECTOS");
        else
            $display("ERROR EN FLAGS");


        #1000;

        $finish;

    end

endmodule