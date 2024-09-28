`include "defines.vh"
`timescale 1ns / 1ps

module SEXT(
    input  wire [24:0] imm,
    input  wire [2:0] op,
    output reg [31:0] ext
);

    // inner logic of SEXT
    always @(*) begin
        case (op)
            `SEXT_OP_I: ext = {{20{imm[24]}}, imm[24:13]};
            `SEXT_OP_S: ext = {{20{imm[24]}}, imm[24:18], imm[4:0]};
            `SEXT_OP_U: ext = {imm[24:5], 12'b0};
            `SEXT_OP_B: ext = {{20{imm[24]}},imm[0],imm[23:18],imm[4:1],1'b0};
            `SEXT_OP_J: ext = {{12{imm[24]}}, imm[12:5], imm[13], imm[23:14], 1'b0};
            default: ext = 32'b0;
        endcase
    end

endmodule
