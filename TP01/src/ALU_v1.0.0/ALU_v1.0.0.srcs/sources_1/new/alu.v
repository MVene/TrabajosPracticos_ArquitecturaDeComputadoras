module alu #(parameter DATA_WIDTH = 8)(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input  [5:0] Op,
    output reg [DATA_WIDTH-1:0] Result
);
    always @(*) begin
        case (Op)
            6'b100000: Result = A + B;       // ADD
            6'b100010: Result = A - B;       // SUB
            6'b100100: Result = A & B;       // AND
            6'b100101: Result = A | B;       // OR
            6'b100110: Result = A ^ B;       // XOR
            6'b000011: Result = $signed(A) >>> 1; // SRA
            6'b000010: Result = A >> 1;      // SRL
            6'b100111: Result = ~(A | B);    // NOR
            default:   Result = 0;
        endcase
    end
endmodule
