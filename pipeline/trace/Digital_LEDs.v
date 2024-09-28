`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 20:04:22
// Design Name: 
// Module Name: Digital_LEDs
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


module Digital_LEDs(
    input wire        clk,
    input wire        rst,
    input wire [31:0] addr,
    input wire        we,
    input wire [31:0] wdata,

    output reg [ 7:0] dig_en,
    output wire        DN_A,
    output wire        DN_B,
    output wire        DN_C,
    output wire        DN_D,
    output wire        DN_E,
    output wire        DN_F,
    output wire        DN_G,
    output wire        DN_DP
    );

    wire rst_n = ~rst;
    wire [63:0] r;
    reg [31:0] wD;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            wD <= 32'h0;
        end else if(we && addr == 32'hFFFFF000) begin
            wD <= wdata;
        end else begin
            wD <= wD;
        end
    end

    reg clk_1k;
    reg [16:0] cnt;
    reg [3:0] display;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 0;
        else if(cnt >= 17'd19999)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            clk_1k <= 0;
        else if(cnt == 17'd19999)
            clk_1k <= 1'b1;
        else
            clk_1k <= 0;
    end


    reg [2:0] num_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            num_cnt <= 0;
        else if(clk_1k)
            num_cnt <= num_cnt + 1'b1;
    end

    always @(posedge clk) begin
        case (num_cnt)
            3'h0: dig_en = 8'b11111110;
            3'h1: dig_en = 8'b11111101;
            3'h2: dig_en = 8'b11111011;
            3'h3: dig_en = 8'b11110111;
            3'h4: dig_en = 8'b11101111;
            3'h5: dig_en = 8'b11011111;
            3'h6: dig_en = 8'b10111111;
            3'h7: dig_en = 8'b01111111;
        endcase
    end

    always @(posedge clk) begin
        case (num_cnt)
            3'h7: display = wD[31:28];
            3'h6: display = wD[27:24];
            3'h5: display = wD[23:20];
            3'h4: display = wD[19:16];
            3'h3: display = wD[15:12];
            3'h2: display = wD[11:8];
            3'h1: display = wD[7:4];
            3'h0: display = wD[3:0];
        endcase
        
    end

    reg [7:0] seg;
    always @(posedge clk) begin
        case (display)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
        endcase
    end

    assign DN_A = seg[0];
    assign DN_B = seg[1];
    assign DN_C = seg[2];
    assign DN_D = seg[3];
    assign DN_E = seg[4];
    assign DN_F = seg[5];
    assign DN_G = seg[6];
    assign DN_DP = seg[7];
endmodule
