`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 20:04:43
// Design Name: 
// Module Name: button
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


module button(
    input wire rst,
    input wire clk,
    input wire [31:0] addr,
    input wire [ 4:0] button,
    output reg [31:0] rdata
    );

    wire rst_n = ~rst;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rdata <= 32'h0;
        end else if (addr == 32'hFFFFF078)begin
            rdata <= {27'b0,button};
        end else begin
            rdata <= rdata;
        end
    end
endmodule
