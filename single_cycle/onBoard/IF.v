`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 20:28:09
// Design Name: 
// Module Name: IF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF(
    input  wire        clk     ,
    input  wire        rst   ,

    input  wire [2:0] funct3,

    input  wire [1:0]  npc_op  ,

    input  wire [31:0] sext_ext,
    input  wire [31:0] aluc   ,
    input  wire        aluf,

    output wire [31:0] pc      ,
    output wire [31:0] pc4
    );

    wire [31:0] npc;

    reg br;

    always @(*) begin
        case (funct3)
            3'b000: br = (aluc==32'b0) ? 1'b1 : 1'b0; //beq
            3'b001: br = (aluc==32'b0) ? 1'b0 : 1'b1; //bne
            3'b100: br = aluf ? 1'b1 : 1'b0; //blt
            3'b101: br = aluf ? 1'b0 : 1'b1; //bge
            default: br = 1'b0;
        endcase
    end

    

    NPC U_NPC (
        .PC         (pc),                // input  wire [31:0]
        .offset     (sext_ext),              // input  wire [31:0]
        .br         (br),                 // input  wire
        .op         (npc_op),             //input   wire [1:0]  
        .aluc       (aluc),                    // input  wire [31:0]
        .npc        (npc),               // output reg [31:0]
        .pc4        (pc4)               // output wire [31:0]
        
    );

    PC U_PC (
        .rst        (rst),              // input  wire
        .clk        (clk),              // input  wire
        .din        (npc),              // input  wire [31:0]
        .pc         (pc)                 // output reg  [31:0]
    );

endmodule
