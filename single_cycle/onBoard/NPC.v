`include "defines.vh"
`timescale 1ns / 1ps

module NPC(
    input  wire [31:0] PC,
    input  wire [31:0] offset,
    input  wire        br,
    input  wire [1:0]  op,
    input  wire [31:0] aluc,
    output reg [31:0] npc,
    output wire [31:0] pc4
);

    // inner logic of NPC
    assign pc4 = PC + 4;

    always @(*) begin
        case (op)
            `NPC_OP_PC4: npc = pc4;
            `NPC_OP_B: begin
                if(br) begin
                    npc = PC + offset;
                end else begin
                    npc = pc4;
                end
            end
            `NPC_OP_JAL: npc = PC + offset;
            `NPC_OP_JALR: npc = aluc;
            default: npc = pc4;
        endcase
    end

endmodule
