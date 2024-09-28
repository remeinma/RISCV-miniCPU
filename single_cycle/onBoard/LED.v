`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 19:47:47
// Design Name: 
// Module Name: LED
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


module LED(
    input wire rst,
    input wire clk,
    input wire [31:0] addr,
    input wire we,
    input wire [31:0] wdata,
    output reg [23:0] led
    );

    wire rst_n = ~rst;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            led <= 24'h0;
        end else if (we && addr == 32'hFFFFF060) begin
            led <= wdata[23:0];
        end else begin
            led <= led;
        end
    end
endmodule
