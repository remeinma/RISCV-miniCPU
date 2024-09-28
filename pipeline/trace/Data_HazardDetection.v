`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:24:39
// Design Name: 
// Module Name: Data_HazardDetection
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


module Data_HazardDetection(
    input wire [4 :0] rR1_ID,
    input wire [4 :0] rR2_ID,

    input wire        read_rD1,
    input wire        read_rD2,
    input wire [1 :0] rf_wsel,

    input wire [4 :0] wR_EX,
    input wire [4 :0] wR_MEM,
    input wire [4 :0] wR_WB,

    input wire [31:0] wD_EX,
    input wire [31:0] wD_MEM,
    input wire [31:0] wD_WB,

    input wire        rf_we_EX,
    input wire        rf_we_MEM,
    input wire        rf_we_WB,
    
    //前递
    output wire       forward_op1,
    output wire       forward_op2,
    output reg [31:0] rD1_forward,
    output reg [31:0] rD2_forward,

    //停顿
    output reg        pipeline_stop_PC,
    output reg        pipeline_stop_REG_IF_ID,
    output reg        flush_REG_ID_EX
    );

    // 数据冒险：EX/MEM/WB_wR==rR1/rR2；RF可写，rD1/rD2被使用，wR不为x0。

    //RAW-A 
    wire RAW_A_rR1 = (wR_EX == rR1_ID) && rf_we_EX && read_rD1 && (wR_EX != 5'b0);
    wire RAW_A_rR2 = (wR_EX == rR2_ID) && rf_we_EX && read_rD2 && (wR_EX != 5'b0);

    //RAW-B
    wire RAW_B_rR1 = (wR_MEM == rR1_ID) && rf_we_MEM && read_rD1 && (wR_MEM != 5'b0);
    wire RAW_B_rR2 = (wR_MEM == rR2_ID) && rf_we_MEM && read_rD2 && (wR_MEM != 5'b0);

    //RAW-C
    wire RAW_C_rR1 = (wR_WB == rR1_ID) && rf_we_WB && read_rD1 && (wR_WB != 5'b0);
    wire RAW_C_rR2 = (wR_WB == rR2_ID) && rf_we_WB && read_rD2 && (wR_WB != 5'b0);

    // 前递
    assign forward_op1 = RAW_A_rR1 | RAW_B_rR1 | RAW_C_rR1;
    assign forward_op2 = RAW_A_rR2 | RAW_B_rR2 | RAW_C_rR2;

    always @ (*) begin
        if (RAW_A_rR1)      rD1_forward = wD_EX;
        else if (RAW_B_rR1) rD1_forward = wD_MEM;
        else if (RAW_C_rR1) rD1_forward = wD_WB;
        else                rD1_forward = 32'b0;
    end

    always @ (*) begin
        if (RAW_A_rR2)      rD2_forward = wD_EX;
        else if (RAW_B_rR2) rD2_forward = wD_MEM;
        else if (RAW_C_rR2) rD2_forward = wD_WB;
        else                rD2_forward = 32'b0;
    end

    // LOAD冒险
    wire load_hazard = (RAW_A_rR1 || RAW_A_rR2) && (rf_wsel == `RF_WSEL_RDO);

    always @ (*) begin
        if(load_hazard)  begin
            pipeline_stop_PC = 1'b1;
            pipeline_stop_REG_IF_ID = 1'b1;
            flush_REG_ID_EX = 1'b1;
        end
        else begin
            pipeline_stop_PC = 1'b0;
            pipeline_stop_REG_IF_ID = 1'b0;
            flush_REG_ID_EX = 1'b0;
        end
    end
endmodule
