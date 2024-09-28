`include "defines.vh"
`timescale 1ns / 1ps

module ALU(
    input  wire [2:0] op,      // 实际位宽与运算种类有关
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg [31:0] C,
    output wire        f
);

    // inner logic of ALU
    assign f = C[31]; //A-B>=0 f=0
    wire [4 :0]shamt = B[4:0];

    always @(*) begin
        case (op)
            `ALU_OP_ADD: C = A+B;
            `ALU_OP_AND: C = A&B;
            `ALU_OP_OR: C = A|B;
            `ALU_OP_XOR: C = A^B;
            `ALU_OP_SLL: C = A<<shamt;
            `ALU_OP_SRL: C = A>>shamt;
            `ALU_OP_SRA: C = $signed(A)>>>shamt;
            `ALU_OP_SUB: C = A-B;
            default: C = 32'b0;
        endcase
    end


endmodule
