`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/24 18:59:35
// Design Name: 
// Module Name: REG_IF_ID
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


module REG_IF_ID(
    input wire clk,
    input wire rst,
    input wire [31:0] inst_in,
    input wire [31:0] pc_in,
    input wire [31:0] pc4_in,
    input wire pipeline_stop,
    input wire flush,

    output reg [31:0] pc_out,
    output reg [31:0] pc4_out,
    output reg [31:0] inst_out
    );

    wire rst_n = ~rst;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)          pc_out <= 32'b0;
        else if (flush)     pc_out <= 32'b0;
        else if (pipeline_stop) pc_out <= pc_out;
        else                pc_out <= pc_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)          pc4_out <= 32'b0;
        else if (flush)     pc4_out <= 32'b0;
        else if (pipeline_stop) pc4_out <= pc4_out;
        else                pc4_out <= pc4_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)          inst_out <= 32'b0;
        else if (flush)     inst_out <= 32'b0;
        else if (pipeline_stop) inst_out <= inst_out;
        else                inst_out <= inst_in;
    end
endmodule
