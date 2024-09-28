`include "defines.vh"
`timescale 1ns / 1ps

module NPC(
    input  wire [31:0] PC,
    input  wire [31:0] pc_jump,
    input  wire   op,
    output wire [31:0] npc,
    output wire [31:0] pc4
);

    // inner logic of NPC
    assign pc4 = PC + 4;

    assign npc = op ? pc_jump : PC + 32'd4;

endmodule
