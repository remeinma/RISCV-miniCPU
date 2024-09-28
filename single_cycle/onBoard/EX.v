`include "defines.vh"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 20:59:05
// Design Name: 
// Module Name: EX
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


module EX(
    input  wire [2:0]  alu_op  ,
    input  wire        alub_sel,

    input  wire [31:0] rf_rd1  ,
    input  wire [31:0] rf_rd2  ,
    input  wire [31:0] sext_ext,

    output wire [31:0] C   ,
    output wire        f
    );

    reg [31:0] B;

    // MUX2_1
    always @ (*) begin
        case (alub_sel)
            `ALUB_SEL_RD2  : B = rf_rd2;
            `ALUB_SEL_EXT: B = sext_ext;
            default        : B = rf_rd2;
        endcase
    end
    ALU U_ALU (
        .op         (alu_op),          // input  wire [ 0:0]
        .A          (rf_rd1),               // input  wire [31:0]
        .B          (B),     // input  wire [31:0]
        .C          (C),                 // output wire [31:0]
        .f          (f)                 //output wire
    );
endmodule
