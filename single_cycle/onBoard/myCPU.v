`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO: 完成你自己的单周期CPU设计
    //
    // 数据信号
    // IF
    wire [31:0] NPC_PC4;
    wire [31:0] PC_pc;

    // ID
    wire [31:0] SEXT_ext;
    wire [31:0] RF_rD1;
    wire [31:0] RF_rD2;
    wire [31:0] RF_wD;

    //EX
    wire [31:0] ALU_C;
    wire        ALU_f;

    //MEM
    wire [31:0] DRAM_rdo;

    // 控制信号
    wire        Ctrl_rf_we;
    wire [2:0] Ctrl_alu_op;
    wire        Ctrl_alub_sel;
    wire        Ctrl_ram_we;
    wire [1:0]    Crtl_npc_op;
    wire [2:0]    Crtl_sext_op;
    wire [1:0]    Ctrl_rf_wsel;

    wire [6:0] opcode = inst[6:0];
    wire [6:0] funct7 = inst[31:25];
    wire [2:0] funct3 = inst[14:12];

    IF U_IF (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire

        .sext_ext     (SEXT_ext),              // input  wire [31:0]
        .aluf         (ALU_f),                 // input  wire
        .npc_op         (Crtl_npc_op),             //input   wire [1:0]  
        .aluc       (ALU_C),                    // input  wire [31:0]
        .funct3       (funct3),                     // input  wire [2:0]

        .pc         (PC_pc),                 // output reg  [31:0]
        .pc4        (NPC_PC4)               // output wire [31:0]
    );

    ID U_ID (
        .clk        (cpu_clk),      // input  wire
        .rst        (cpu_rst),      // input  wire

        .sext_op    (Crtl_sext_op),     //input wire [2:0]
        .rf_we      (Ctrl_rf_we),       // input  wire
        .rf_wsel    (Ctrl_rf_wsel),     // input  wire [1:0]

        .inst       (inst),        // input wire  [31:0]
        .aluc       (ALU_C),            // input wire  [31:0]
        .DRAM_rdo   (DRAM_rdo),         // input wire  [31:0]
        .npc_pc4    (NPC_PC4),          // input wire  [31:0]

        .sext_ext   (SEXT_ext),         // input wire  [31:0]
        .rf_rd1     (RF_rD1),           // output wire  [31:0]
        .rf_rd2     (RF_rD2)//,            // output wire  [31:0]
        // .rf_wd      (RF_wD)            // output reg  [31:0]

    );

    EX U_EX (
        .alu_op         (Ctrl_alu_op),          // input  wire [2:0]
        .alub_sel       (Ctrl_alub_sel),         // input  wire

        .rf_rd1          (RF_rD1),               // input  wire [31:0]
        .rf_rd2          (RF_rD2),     // input  wire [31:0]
        .sext_ext       (SEXT_ext),
        .C          (ALU_C),                 // output wire [31:0]
        .f          (ALU_f)                //output wire
    );



    Ctrl U_Ctrl (
        .opcode     (opcode),       // input  wire [6:0]
        .funct7     (funct7),     // input  wire [6:0]
        .funct3     (funct3),     // input  wire [2:0]

        .rf_we      (Ctrl_rf_we),           // output wire

        .alu_op     (Ctrl_alu_op),          // output wire [2:0]
        .alub_sel   (Ctrl_alub_sel),        // output wire
        
        .ram_we     (Ctrl_ram_we),           // output wire

        .sext_op    (Crtl_sext_op),     // output wire [2:0]
        .npc_op     (Crtl_npc_op),          // output wire [1:0]
        .rf_wsel    (Ctrl_rf_wsel)       // output wire [1:0]
    );

    

    // assign
    
`ifdef RUN_TRACE
    assign inst_addr = PC_pc[17:2];
`else
    assign inst_addr = PC_pc[15:2];
`endif

    assign Bus_addr = ALU_C;
    assign Bus_we = Ctrl_ram_we;
    assign Bus_wdata = RF_rD2;

    assign DRAM_rdo = Bus_rdata;


    // END

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1'b1/* TODO */;
    assign debug_wb_pc        = PC_pc/* TODO */;
    assign debug_wb_ena       = Ctrl_rf_we/* TODO */;
    assign debug_wb_reg       = inst[11:7]/* TODO */;
    assign debug_wb_value     = RF_wD/* TODO */;
`endif

endmodule
