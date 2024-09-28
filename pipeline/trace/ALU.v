`include "defines.vh"
`timescale 1ns / 1ps

module ALU(
    input  wire alub_sel,
    input  wire [3:0] alu_op,      // 实际位宽与运算种类有关
    input  wire [31:0] rD1,
    input  wire [31:0] rD2,
    input  wire [31:0] imm,
    output reg [31:0] C,
    output reg        f
);

    reg [31:0] B;
    wire [31:0] A = rD1;
    always @ (*) begin
        case (alub_sel)
            `ALUB_SEL_RD2  : B = rD2;
            `ALUB_SEL_EXT: B = imm;
            default        : B = rD2;
        endcase
    end

    // inner logic of ALU

    wire [4 :0]shamt = B[4:0];

    always @(*) begin
        case (alu_op)
            `ALU_OP_ADD: C = A+B;
            `ALU_OP_AND: C = A&B;
            `ALU_OP_OR: C = A|B;
            `ALU_OP_XOR: C = A^B;
            `ALU_OP_SLL: C = A<<shamt;
            `ALU_OP_SRL: C = A>>shamt;
            `ALU_OP_SRA: C = $signed(A)>>>shamt;
            `ALU_OP_SUB: C = A-B;
            `ALU_OP_BEQ: f = (A==B)? 1'b1 : 1'b0;
            `ALU_OP_BNE: f = (A!=B)? 1'b1 : 1'b0;
            `ALU_OP_BLT: begin
                C = A+(~B)+1;
                f = (C[31])?  1'b1 : 1'b0;
            end
            `ALU_OP_BGE: begin
                C = A+(~B)+1;
                f = (~C[31])?  1'b1 : 1'b0;
            end
            default: C = 32'b0;
        endcase
    end


endmodule
