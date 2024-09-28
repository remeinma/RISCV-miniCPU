`include "defines.vh"
`timescale 1ns / 1ps

module Ctrl(
    input  wire [6:0] opcode,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,

    output wire read_rD1,
    output wire read_rD2,
    output wire [2:0] branch,
    output reg have_inst,

    output reg       rf_we,

    output reg  [3:0] alu_op,
    output reg       alub_sel,
    
    output reg       ram_we,

    output reg [2:0] sext_op,
    // output reg [1:0] npc_op,
    output reg [1:0] rf_wsel
);

    // inner logic of CTRL


    // // npc_op
    // always @(*) begin
    //     case (opcode)
    //         `OP_R,`OP_I,`OP_LOAD,`OP_S,`OP_LUI: 
    //             npc_op = `NPC_OP_PC4;
    //         `OP_B: npc_op = `NPC_OP_B;
    //         `OP_JAL: npc_op = `NPC_OP_JAL;
    //         `OP_JALR: npc_op = `NPC_OP_JALR;
    //         default: npc_op = `NPC_OP_PC4;
    //     endcase
    // end

    assign read_rD1 = (opcode == `OP_R) | (opcode == `OP_LOAD) | (opcode == `OP_JALR) | (opcode == `OP_I) | (opcode == `OP_S) | (opcode == `OP_B);
    assign read_rD2 = (opcode == `OP_R) | (opcode == `OP_LOAD) | (opcode == `OP_JALR) | (opcode == `OP_S) | (opcode == `OP_B);

    wire is_B = (opcode == `OP_B)? 1'b1 : 1'b0;
    wire is_JAL = (opcode == `OP_JAL)? 1'b1 : 1'b0;
    wire is_JALR = (opcode == `OP_JALR)? 1'b1 : 1'b0;
    assign branch = {is_B, is_JAL, is_JALR};


    // have_inst
    always @(*) begin
        case (opcode)
            `OP_R,`OP_I,`OP_LOAD,`OP_S,`OP_LUI,`OP_B,`OP_JAL,`OP_JALR: 
                have_inst = 1'b1;
            default: have_inst = 1'b0;
        endcase
    end

    // rf_we
    always @(*) begin
        case (opcode)
            `OP_R,`OP_I,`OP_LOAD,`OP_LUI,`OP_JAL,`OP_JALR:
                rf_we = 1'b1;
            `OP_S,`OP_B: rf_we = 1'b0;
            default: rf_we = 1'b0;
        endcase
    end

    // rf_wsel
    always @(*) begin
        case (opcode)
            `OP_R,`OP_I: rf_wsel = `RF_WSEL_ALUC;
            `OP_LOAD: rf_wsel = `RF_WSEL_RDO;
            `OP_S,`OP_LUI: rf_wsel = `RF_WSEL_EXT;
            `OP_JAL,`OP_JALR: rf_wsel = `RF_WSEL_PC4;
            default: rf_wsel = `RF_WSEL_DEFAULT;
        endcase
    end

    // sext_op
    always @(*) begin
        case (opcode)
            `OP_R: sext_op = `SEXT_OP_DEAFAULT;
            `OP_I,`OP_LOAD,`OP_JALR: sext_op = `SEXT_OP_I;
            `OP_S: sext_op = `SEXT_OP_S;
            `OP_B: sext_op = `SEXT_OP_B;
            `OP_LUI: sext_op = `SEXT_OP_U;
            `OP_JAL: sext_op = `SEXT_OP_J;
            default: sext_op = `SEXT_OP_DEAFAULT;
        endcase
    end

    // alu_op
    always @(*) begin
        case (opcode)
            `OP_R: begin
                case (funct3)
                    3'b000: alu_op = funct7[5] ? `ALU_OP_SUB : `ALU_OP_ADD;
                    3'b001: alu_op = `ALU_OP_SLL;
                    3'b100: alu_op = `ALU_OP_XOR;
                    3'b101: alu_op = funct7[5] ? `ALU_OP_SRA : `ALU_OP_SRL;
                    3'b110: alu_op = `ALU_OP_OR;
                    3'b111: alu_op = `ALU_OP_AND;
                    default: alu_op = `ALU_OP_AND;
                endcase
            end
            `OP_I: begin
                case (funct3)
                    3'b000: alu_op = `ALU_OP_ADD;
                    3'b001: alu_op = `ALU_OP_SLL;
                    3'b100: alu_op = `ALU_OP_XOR;
                    3'b101: alu_op = funct7[5] ? `ALU_OP_SRA : `ALU_OP_SRL;
                    3'b110: alu_op = `ALU_OP_OR;
                    3'b111: alu_op = `ALU_OP_AND;
                    default: alu_op = `ALU_OP_AND;
                endcase
            end
            `OP_LOAD,`OP_JALR,`OP_S: alu_op = `ALU_OP_ADD;
            `OP_B: begin
                case (funct3)
                    3'b000: alu_op = `ALU_OP_BEQ;
                    3'b001: alu_op = `ALU_OP_BNE;
                    3'b100: alu_op = `ALU_OP_BLT;
                    3'b101: alu_op = `ALU_OP_BGE;
                    default: alu_op = `ALU_OP_BEQ;
                endcase
            end
            default: alu_op = `ALU_OP_AND;
        endcase
    end

    // alub_sel
    always @(*) begin
        case (opcode)
            `OP_R,`OP_B: alub_sel = `ALUB_SEL_RD2;
            `OP_I,`OP_LOAD,`OP_JALR,`OP_S: alub_sel = `ALUB_SEL_EXT;
            default: alub_sel = `ALUB_SEL_RD2;
        endcase
    end

    // ram_we
    always @(*) begin
        if (opcode == `OP_S) begin
            ram_we = `WRITE;
        end else begin
            ram_we = `READ;
        end
    end


endmodule
