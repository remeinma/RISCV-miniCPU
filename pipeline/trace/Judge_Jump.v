`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 14:31:24
// Design Name: 
// Module Name: Judge_Jump
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


module Judge_Jump(
    input wire [2:0] branch,
    input wire bf,
    input wire [31:0] imm,
    input wire [31:0] PC,
    input wire [31:0] PC4,
    input wire [31:0] aluc,

    output reg npc_op,
    output reg [31:0] pc_jump
    );

    always @(*) begin
        if(branch[2] & bf)      pc_jump = PC+imm;      //B+跳转
        else if(branch[1])      pc_jump = PC+imm;      //JAL
        else if(branch[0])      pc_jump = aluc;        //JALR
        else                    pc_jump = PC+32'd4;
    end

    always @(*) begin
        if(branch[2] & bf)          npc_op = 1'b1;          //B+跳转
        else if(branch[2] & !bf)    npc_op = 1'b0;          //B+不跳转
        else if(branch[1])          npc_op = 1'b1;          //JAL
        else if(branch[0])          npc_op = 1'b1;          //JALR
        else                        npc_op = 1'b0; 
    end
endmodule
