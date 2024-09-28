`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:01:10
// Design Name: 
// Module Name: REG_MEM_WB
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


module REG_MEM_WB(
    input wire        clk,
    input wire        rst,  
    
    input wire [4 :0] wR_in,
    input wire [31:0] wD_in,
    input wire [31:0] pc_in,
    input wire        have_inst_in,
    input wire        rf_we_in,

    output reg [4 :0] wR_out,
    output reg [31:0] wD_out,
    output reg [31:0] pc_out,
    output reg        have_inst_out,
    output reg        rf_we_out
    );

    wire rst_n = ~rst;

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)      wR_out <= 5'b0;
        else         wR_out <= wR_in;
    end

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)      wD_out <= 32'b0;
        else         wD_out <= wD_in;
    end

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)      pc_out <= 32'b0;
        else         pc_out <= pc_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)      have_inst_out <= 1'b0;
        else         have_inst_out <= have_inst_in;
    end

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)      rf_we_out <= 1'b0;
        else         rf_we_out <= rf_we_in;
    end

endmodule
