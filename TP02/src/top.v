module top (
    input clk, rst,
    input rx,              // UART RX desde PC
    output tx,             // UART TX hacia PC
    output [7:0] leds      // LEDs muestran resultado ALU
);

    // Señales internas
    wire [7:0] rx_data;
    wire rx_ready;
    wire alu_start, tx_start;
    wire [2:0] alu_op;
    wire [7:0] operand_a, operand_b;
    wire [7:0] alu_result;

    // Instancia UART RX
    uart_rx u_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Instancia FSM
    fsm_control u_fsm (
        .clk(clk),
        .rst(rst),
        .rx_ready(rx_ready),
        .rx_data(rx_data),
        .alu_start(alu_start),
        .tx_start(tx_start),
        .alu_op(alu_op),
        .operand_a(operand_a),
        .operand_b(operand_b)
    );

    // Instancia ALU
    alu #(
        .DATA_WIDTH(8),
        .OP_WIDTH(6)
    ) u_alu (
        .i_a(operand_a),
        .i_b(operand_b),
        .i_op(alu_op),
        .o_result(alu_result),
        .o_negative(),
        .o_zero(),
        .o_carry()
    );


    // Instancia UART TX
    uart_tx u_tx (
        .clk(clk),
        .rst(rst),
        .tx_data(alu_result),
        .tx_start(tx_start),
        .tx(tx)
    );

    // LEDs muestran resultado
    assign leds = alu_result;

endmodule
