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
    output [2:0]               o_flags  // {o_negative, o_zero, o_overflow}
);

    wire en_A   = (i_btn[0] == 1'b1) ? i_btn[0] : 1'b0; 
    wire en_B   = (i_btn[1] == 1'b1) ? i_btn[1] : 1'b0;  
    wire en_Op  = (i_btn[2] == 1'b1) ? i_btn[2] : 1'b0;
    wire en_rst = (i_btn[3] == 1'b1) ? i_btn[3] : 1'b0;

    reg [DATA_WIDTH-1:0] reg_A  = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] reg_B  = {DATA_WIDTH{1'b0}};
    reg [OP_WIDTH-1:0]   reg_Op = 6'b000000;  

    always @(posedge i_clk) begin
        if (en_rst) begin
            reg_A  <= {DATA_WIDTH{1'b0}};
            reg_B  <= {DATA_WIDTH{1'b0}};
            reg_Op <= 6'b000000;  
        end 
        else begin
            if (en_A)
                reg_A <= i_sw;

            if (en_B)
                reg_B <= i_sw;

            if (en_Op) 
                reg_Op <= i_sw[OP_WIDTH-1:0];
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
