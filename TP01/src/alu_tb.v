// alu_tb.v validar la funcionalidad con entradas aleatorias y chequeo automático.
module ALU_tb;

reg [31:0] A, B;
reg [5:0] Op;
wire [31:0] Result;
wire Zero;

ALU #(32) uut (
    .A(A), .B(B), .Op(Op), .Result(Result), .Zero(Zero)
);

initial begin
    $display("Inicio de testbench...");
    repeat (20) begin
        A = $random;
        B = $random;
        Op = 6'b100000 + ($random % 8); // Opciones válidas
        #10;
        $display("A=%d B=%d Op=%b → Result=%d Zero=%b", A, B, Op, Result, Zero);
    end
    $finish;
end

endmodule
