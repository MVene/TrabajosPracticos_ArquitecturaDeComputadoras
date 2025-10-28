// alu.v Este módulo recibe dos operandos, un código de operación, y devuelve el resultado.
module ALU #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [5:0] Op,
    output reg [WIDTH-1:0] Result,
    output Zero
);

assign Zero = (Result == 0);

always @(*) begin
    case (Op)
        6'b100000: Result = A + B;       // ADD
        6'b100010: Result = A - B;       // SUB
        6'b100100: Result = A & B;       // AND
        6'b100101: Result = A | B;       // OR
        6'b100110: Result = A ^ B;       // XOR
        6'b000011: Result = A >>> B;     // SRA
        6'b000010: Result = A >> B;      // SRL
        6'b100111: Result = ~(A | B);    // NOR
        default:   Result = 0;
    endcase
end

endmodule
