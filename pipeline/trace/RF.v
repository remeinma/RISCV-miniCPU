`timescale 1ns / 1ps

module RF(
    input  wire        clk,
    input  wire        rst,

    input  wire [4:0] rR1,
    output wire  [31:0] rD1,
    
    input  wire [4:0] rR2,
    output wire  [31:0] rD2,
    
    input  wire        we,
    input  wire [4:0] wR,
    input  wire [31:0] wD
);

    // inner logic of RF

    reg [31:0] rf[31:0];
    wire rst_n = ~rst;

    // read data, no clk
    assign rD1 = rf[rR1];
    assign rD2 = rf[rR2];

    // write data, with clk
    always @(posedge clk or negedge rst_n) begin
        //write enable, x0=0
        if (~rst_n) begin
            rf[0]  <= 32'b0;
            rf[1]  <= 32'b0;
            rf[2]  <= 32'b0;
            rf[3]  <= 32'b0;
            rf[4]  <= 32'b0;
            rf[5]  <= 32'b0;
            rf[6]  <= 32'b0;
            rf[7]  <= 32'b0;
            rf[8]  <= 32'b0;
            rf[9]  <= 32'b0;
            rf[10] <= 32'b0;
            rf[11] <= 32'b0;
            rf[12] <= 32'b0;
            rf[13] <= 32'b0;
            rf[14] <= 32'b0;
            rf[15] <= 32'b0;
            rf[16] <= 32'b0;
            rf[17] <= 32'b0;
            rf[18] <= 32'b0;
            rf[19] <= 32'b0;
            rf[20] <= 32'b0;
            rf[21] <= 32'b0;
            rf[22] <= 32'b0;
            rf[23] <= 32'b0;
            rf[24] <= 32'b0;
            rf[25] <= 32'b0;
            rf[26] <= 32'b0;
            rf[27] <= 32'b0;
            rf[28] <= 32'b0;
            rf[29] <= 32'b0;
            rf[30] <= 32'b0;
            rf[31] <= 32'b0;
        end else if(we && wR) begin
            rf[wR] <= wD;
        end else begin
            rf[0] <= 32'b0;
        end
    end

endmodule
