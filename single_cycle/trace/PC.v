`timescale 1ns / 1ps

module PC(
    input  wire        rst,
    input  wire        clk,
    input  wire [31:0] din,
    output reg  [31:0] pc
);

    // inner logic of PC
    wire rst_n = ~rst;

    reg flag;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            pc <= 32'h0;
            flag <= 1'b0;
        end else begin
            if(flag) begin
                pc <= din;
            end else begin
                flag <= 1'b1;
            end
            
        end
    end

endmodule
