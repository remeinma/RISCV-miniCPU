`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:22:02
// Design Name: 
// Module Name: Control_HazardDetection
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


module Control_HazardDetection(
    input wire        is_control_hazard,

    output wire       flush_REG_ID_EX,
    output wire       flush_REG_IF_ID
    );

    assign flush_REG_ID_EX = is_control_hazard? 1'b1 :1'b0;
    assign flush_REG_IF_ID = is_control_hazard? 1'b1 :1'b0;
endmodule
