`include "defines.vh"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 20:43:33
// Design Name: 
// Module Name: ID
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


module ID(
    input  wire        clk      ,
    input  wire        rst    ,

    input  wire [2:0]  sext_op  ,
    input  wire        rf_we    ,
    input  wire [1:0]  rf_wsel   ,

    input  wire [31:0] inst,

    input  wire [31:0] aluc    ,
    input  wire [31:0] DRAM_rdo  ,
    input  wire [31:0] npc_pc4  ,
    input wire [31:0] sext_ext ,
    
    output wire [31:0] rf_rd1   ,
    output wire [31:0] rf_rd2  // ,
    // output reg [31:0] rf_wd
    
    );

    reg [31:0] rf_wd;

    // MUX4_1
    always @ (*) begin
        case (rf_wsel)
            `RF_WSEL_ALUC   : rf_wd = aluc;
            `RF_WSEL_RDO : rf_wd = DRAM_rdo;
            `RF_WSEL_PC4 : rf_wd = npc_pc4;
            `RF_WSEL_EXT: rf_wd = sext_ext;
            default  : rf_wd = aluc;
        endcase
    end


    wire [4:0] rR1 = inst[19:15];
    wire [4:0] rR2 = inst[24:20];
    wire [4:0] wR = inst[11:7];

    RF U_RF (
        .clk        (clk),              // input  wire
        .rst        (rst),              // input  wire

        .rR1        (rR1),     // input  wire [ 4:0]
        .rD1        (rf_rd1),               // output reg  [31:0]
        
        .rR2        (rR2),     // input  wire [ 4:0]
        .rD2        (rf_rd2),               // output reg  [31:0]
        
        .we         (rf_we),           // input  wire
        .wR         (wR),      // input  wire [ 4:0]
        .wD         (rf_wd)                 // input  wire [31:0]
    );

    wire [24:0] imm = inst[31:7];
    SEXT U_SEXT (
        .op         (sext_op),             //input wire [2:0]
        .imm        (imm),  // input  wire [31:7]
        .ext        (sext_ext)              // output wire [31:0]
    );

endmodule
