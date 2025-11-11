`timescale 1ns / 1ps

module alu_top #(
    parameter DATA_WIDTH = 8,
    parameter BTN_COUNT  = 4,
    parameter OP_WIDTH = 6
)(
    input                      i_clk,
    input  [DATA_WIDTH-1:0]    i_sw,
    input  [BTN_COUNT-1:0]     i_btn,
    output [DATA_WIDTH-1:0]    o_led,
    output [2:0]               o_flags  // {o_negative, o_zero, o_carry}
);
    wire en_A   = (BTN_COUNT > 0) ? i_btn[0] : 1'b0;
    wire en_B   = (BTN_COUNT > 1) ? i_btn[1] : 1'b0;
    wire en_Op  = (BTN_COUNT > 2) ? i_btn[2] : 1'b0;
    wire en_rst = (BTN_COUNT > 3) ? i_btn[3] : 1'b0;

    reg [DATA_WIDTH-1:0] reg_A  = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] reg_B  = {DATA_WIDTH{1'b0}};
    reg [OP_WIDTH-1:0]   reg_Op = 6'b100000;  // ADD por defecto

    always @(posedge i_clk) begin
        if (en_rst) begin
            reg_A  <= {DATA_WIDTH{1'b0}};
            reg_B  <= {DATA_WIDTH{1'b0}};
            reg_Op <= 6'b100000;  // vuelve al modo ADD
        end 
        else begin
            if (en_A)
                reg_A <= i_sw;

            if (en_B)
                reg_B <= i_sw;

            if (en_Op) begin
                case (i_sw[5:0])
                    6'b100000: reg_Op <= 6'b100000; // ADD
                    6'b100010: reg_Op <= 6'b100010; // SUB
                    6'b100100: reg_Op <= 6'b100100; // AND
                    6'b100101: reg_Op <= 6'b100101; // OR
                    6'b100110: reg_Op <= 6'b100110; // XOR
                    6'b000011: reg_Op <= 6'b000011; // SRA
                    6'b000010: reg_Op <= 6'b000010; // SRL
                    6'b100111: reg_Op <= 6'b100111; // NOR
                endcase
            end
        end
    end

    wire [DATA_WIDTH-1:0] o_result;
    wire o_negative, o_zero, o_carry;

    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) u_alu (
        .i_a(reg_A),
        .i_b(reg_B),
        .i_op(reg_Op),
        .o_result(o_result),
        .o_negative(o_negative),
        .o_zero(o_zero),
        .o_carry(o_carry)
    );

    assign o_led = o_result;
    assign o_flags = {o_negative, o_zero, o_carry};

endmodule
