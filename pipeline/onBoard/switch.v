`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 20:02:15
// Design Name: 
// Module Name: switch
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


module switch(
    input wire rst,
    input wire clk,
    input wire [31:0] addr,
    input wire [23:0] sw,
    output reg [31:0] rdata
    );

    wire rst_n = ~rst;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            rdata <= 32'h0;
        end else if (addr == 32'hFFFFF070)begin
            rdata <= {8'b0,sw};
        end else begin
            rdata <= rdata;
        end
    end
endmodule
