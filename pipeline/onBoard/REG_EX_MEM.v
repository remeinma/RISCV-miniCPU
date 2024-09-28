`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 14:56:48
// Design Name: 
// Module Name: REG_EX_MEM
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


module REG_EX_MEM(
    // input
    input wire clk,
    input wire rst,
    
    input wire [4:0] wR_in,
    input wire [31:0] rD2_in,
    input wire [31:0] aluc_in,
    input wire [31:0] wD_in,
    input wire [31:0] pc_in,
    input wire       have_inst_in,

    output reg [4:0] wR_out,
    output reg [31:0] rD2_out,
    output reg [31:0] aluc_out,
    output reg [31:0] wD_out,
    output reg [31:0] pc_out,
    output reg       have_inst_out,

    input wire [1 :0] rf_wsel_in,
    input wire        rf_we_in,
    input wire        ram_we_in,

    output reg [1 :0] rf_wsel_out,
    output reg        rf_we_out,
    output reg        ram_we_out
    );

    wire rst_n = ~rst;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           wD_out <= 32'b0;
        else              wD_out <= wD_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           wR_out <= 5'b0;
        else              wR_out <= wR_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           rD2_out <= 32'b0;
        else              rD2_out <= rD2_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           pc_out <= 32'b0;
        else              pc_out <= pc_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           aluc_out <= 32'b0;
        else              aluc_out <= aluc_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           have_inst_out <= 1'b0;
        else              have_inst_out <= have_inst_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           rf_wsel_out <= 2'b0;
        else              rf_wsel_out <= rf_wsel_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           rf_we_out <= 1'b0;
        else              rf_we_out <= rf_we_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)           ram_we_out <= 1'b0;
        else              ram_we_out <= ram_we_in;
    end
endmodule
