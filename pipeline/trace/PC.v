`timescale 1ns / 1ps

module PC(
    input  wire        rst,
    input  wire        clk,
    input  wire [31:0] din,
    input  wire        stop,
    output reg  [31:0] pc
);

    // inner logic of PC
    wire rst_n = ~rst;


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            pc <= 32'h0;
        end else if (stop)begin
            pc <= pc;
        end else begin
            pc <= din;            
        end
    end

endmodule
