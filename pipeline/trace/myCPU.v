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
    wire [31:0] PC4_IF;
    wire [31:0] PC_IF;
    wire [31:0] npc;
    wire [31:0] pc_jump;
    wire        npc_op;
    wire pipeline_stop_PC;
    wire pipeline_stop_REG_IF_ID;
    wire flush_REG_IF_ID;

    // ID
    wire [31:0] PC4_ID;
    wire [31:0] PC_ID;
    wire [31:0] inst_ID;
    wire [31:0] imm_ID;
    wire [31:0] rD1_ID;
    wire [31:0] rD2_ID;
    wire have_inst_ID;

    wire        rf_we_ID;
    wire [3:0] alu_op_ID;
    wire        alub_sel_ID;
    wire        ram_we_ID;
    wire [2:0]    sext_op_ID;
    wire [1:0]    rf_wsel_ID;
    wire [2:0] branch_ID;

    wire read_rD1;
    wire read_rD2;

    // EX
    wire [31:0] PC4_EX;
    wire [31:0] PC_EX;
    wire [31:0] imm_EX;
    wire [31:0] rD1_EX;
    wire [31:0] rD2_EX;
    wire [4:0] wR_EX;
    wire have_inst_EX;

    wire        rf_we_EX;
    wire [3:0] alu_op_EX;
    wire        alub_sel_EX;
    wire        ram_we_EX;
    wire [2:0]    sext_op_EX;
    wire [1:0]    rf_wsel_EX;
    wire [2:0] branch_EX;

    wire forward_op1;
    wire forward_op2;
    wire [31:0] rD1_forward;
    wire [31:0] rD2_forward;
    wire flush_REG_ID_EX;

    wire [31:0] aluc_EX;
    wire bf_EX ;

    reg [31:0] wD_EX;

    // MEM
    wire [4:0] wR_MEM;
    wire [31:0] rD2_MEM;
    wire [31:0] aluc_MEM;
    wire [31:0] wD_MEM;
    wire [31:0] PC_MEM;
    wire have_inst_MEM;

    wire        rf_we_MEM;
    wire        ram_we_MEM;
    wire [1:0]    rf_wsel_MEM;

    reg [31:0] wD;

    wire [31:0] DRAM_rdo;

    // WB
    wire [4:0] wR_WB;
    wire [31:0] wD_WB;
    wire [31:0] PC_WB;
    wire have_inst_WB;

    wire        rf_we_WB;

    // HazardDetection
    wire flush_REG_ID_EX_Control;
    wire flush_REG_ID_EX_Data;


    

/* *****************************IF******************************* */

    PC U_PC (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire
        .din        (npc),              // input  wire [31:0]
        .stop       (pipeline_stop_PC),
        
        .pc         (PC_IF)                 // output reg  [31:0]
    );

    NPC U_NPC (
        .PC         (PC_IF),                // input  wire [31:0]
        .pc_jump     (pc_jump),                 // input  wire
        .op         (npc_op),             //input   wire [1:0]  
        
        .npc        (npc),               // output reg [31:0]
        .pc4        (PC4_IF)               // output wire [31:0]
    );

/* *****************************IF/ID******************************* */

    REG_IF_ID U_REG_IF_ID (
        // input
        .clk    (cpu_clk),
        .rst    (cpu_rst),

        .inst_in   (inst),
        .pc_in      (PC_IF),
        .pc4_in     (PC4_IF),

        .pipeline_stop(pipeline_stop_REG_IF_ID),
        .flush(flush_REG_IF_ID),

        //output
        .pc_out(PC_ID),
        .pc4_out(PC4_ID),
        .inst_out(inst_ID)
    );

/* *****************************ID******************************* */

    SEXT U_SEXT (
        .op         (sext_op_ID),             //input wire [2:0]
        .imm        (inst_ID[31:7]),  // input  wire [31:7]

        .ext        (imm_ID)              // output wire [31:0]
    );


    RF U_RF (
        .clk        (cpu_clk),              // input  wire
        .rst        (cpu_rst),              // input  wire

        .rR1        (inst_ID[19:15]),     // input  wire [ 4:0]
        .rD1        (rD1_ID),               // output reg  [31:0]
        
        .rR2        (inst_ID[24:20]),     // input  wire [ 4:0]
        .rD2        (rD2_ID),               // output reg  [31:0]
        
        .we         (rf_we_WB),           // input  wire
        .wR         (wR_WB),      // input  wire [ 4:0]
        .wD         (wD_WB)                 // input  wire [31:0]
    );

    Ctrl U_Ctrl (
        .opcode     (inst_ID[6:0]),       // input  wire [6:0]
        .funct7     (inst_ID[31:25]),     // input  wire [6:0]
        .funct3     (inst_ID[14:12]),     // input  wire [2:0]

        .read_rD1   (read_rD1),
        .read_rD2   (read_rD2),

        .rf_we      (rf_we_ID),           // output wire

        .alu_op     (alu_op_ID),          // output wire [2:0]
        .alub_sel   (alub_sel_ID),        // output wire
        
        .ram_we     (ram_we_ID),           // output wire

        .sext_op    (sext_op_ID),     // output wire [2:0]
        // .npc_op     (Crtl_npc_op),          // output wire [1:0]
        .rf_wsel    (rf_wsel_ID),       // output wire [1:0]
        .have_inst  (have_inst_ID),
        .branch     (branch_ID)
    );

/* *****************************ID/EX******************************* */

    REG_ID_EX U_REG_ID_EX (
        // input
        .clk    (cpu_clk),
        .rst    (cpu_rst),
        
        .rD1_in (rD1_ID),
        .rD2_in (rD2_ID),
        .wR_in  (inst_ID[11:7]),
        .pc_in      (PC_ID),
        .pc4_in     (PC4_ID),
        .imm_in     (imm_ID),
        .have_inst_in(have_inst_ID),

        // output
        .rD1_out(rD1_EX),
        .rD2_out(rD2_EX),
        .wR_out(wR_EX),
        .pc_out(PC_EX),
        .pc4_out(PC4_EX),
        .imm_out(imm_EX),
        .have_inst_out(have_inst_EX),

        // input
        .rf_wsel_in(rf_wsel_ID),
        .branch_in(branch_ID),
        .rf_we_in(rf_we_ID),
        .alu_op_in(alu_op_ID),
        .alub_sel_in(alub_sel_ID),
        .ram_we_in(ram_we_ID),
        
        // output
        .rf_wsel_out(rf_wsel_EX),
        .branch_out(branch_EX),
        .rf_we_out(rf_we_EX),
        .alu_op_out(alu_op_EX),
        .alub_sel_out(alub_sel_EX),
        .ram_we_out(ram_we_EX),

        //前递相关信号
        .forward_op1(forward_op1),
        .forward_op2(forward_op2),
        .rD1_forward(rD1_forward),
        .rD2_forward(rD2_forward),
        //清除信号
        .flush(flush_REG_ID_EX)
    );

/* *****************************EX******************************* */
    
    ALU U_ALU (
        .alub_sel   (alub_sel_EX),
        .alu_op         (alu_op_EX),          // input  wire [ 0:0]
        .rD1          (rD1_EX),               // input  wire [31:0]
        .rD2          (rD2_EX),     // input  wire [31:0]
        .imm          (imm_EX),     // input  wire [31:0]

        .C          (aluc_EX),                 // output wire [31:0]
        .f          (bf_EX)                 //output wire
    );

    Judge_Jump U_Judge_Jump (
        // input
        .branch(branch_EX),
        .bf(bf_EX),
        .imm(imm_EX),
        .PC(PC_EX),
        .PC4(PC4_EX),
        .aluc(aluc_EX),
        // output
        .npc_op(npc_op),
        .pc_jump(pc_jump)
    );



    // MUX4_1
    always @ (*) begin
        case (rf_wsel_EX)
            `RF_WSEL_ALUC   : wD_EX = aluc_EX;
            // `RF_WSEL_RDO : wD_EX = DRAM_rdo;
            `RF_WSEL_PC4 : wD_EX = PC4_EX;
            `RF_WSEL_EXT: wD_EX = imm_EX;
            default  : wD_EX = aluc_EX;
        endcase
    end
    
/* *****************************EX/MEM******************************* */

    REG_EX_MEM U_REG_EX_MEM (
        // input
        .clk    (cpu_clk),
        .rst    (cpu_rst),
        
        .wR_in  (wR_EX),
        .rD2_in (rD2_EX),
        .aluc_in(aluc_EX),
        .wD_in  (wD_EX),
        .pc_in  (PC_EX),
        .have_inst_in(have_inst_EX),

        .wR_out  (wR_MEM),
        .rD2_out (rD2_MEM),
        .aluc_out(aluc_MEM),
        .wD_out  (wD_MEM),
        .pc_out     (PC_MEM),
        .have_inst_out(have_inst_MEM),

        .ram_we_in  (ram_we_EX),
        .rf_wsel_in (rf_wsel_EX),
        .rf_we_in   (rf_we_EX),

        .ram_we_out  (ram_we_MEM),
        .rf_wsel_out (rf_wsel_MEM),
        .rf_we_out   (rf_we_MEM)
    );

/* *****************************MEM******************************* */

    // MUX2_1
    always @ (*) begin
        case (rf_wsel_MEM)
            `RF_WSEL_ALUC   : wD = wD_MEM;
            `RF_WSEL_RDO : wD = DRAM_rdo;
            `RF_WSEL_PC4 : wD = wD_MEM;
            `RF_WSEL_EXT: wD = wD_MEM;
            default  : wD = 32'h0;
        endcase
    end

/* *****************************MEM/WB******************************* */

    REG_MEM_WB U_REG_MEM_WB(
        .clk(cpu_clk),
        .rst(cpu_rst),

        .wR_in(wR_MEM),
        .wD_in(wD),
        .pc_in(PC_MEM),
        .have_inst_in(have_inst_MEM),
        .rf_we_in(rf_we_MEM),

        .wR_out(wR_WB),
        .wD_out(wD_WB),
        .pc_out(PC_WB),
        .have_inst_out(have_inst_WB),
        .rf_we_out(rf_we_WB)
    );

/* *****************************assign******************************* */

    
`ifdef RUN_TRACE
    assign inst_addr = PC_IF[17:2];
`else
    assign inst_addr = PC_IF[15:2];
`endif

    assign Bus_addr = aluc_MEM;
    assign Bus_we = ram_we_MEM;
    assign Bus_wdata = rD2_MEM;

    assign DRAM_rdo = Bus_rdata;

/* *****************************HazardDetection******************************* */

    assign flush_REG_ID_EX = flush_REG_ID_EX_Control | flush_REG_ID_EX_Data;

    Control_HazardDetection U_Control_HazardDetection(
        //input
        .is_control_hazard(npc_op),       
        //output
        .flush_REG_ID_EX(flush_REG_ID_EX_Control),
        .flush_REG_IF_ID(flush_REG_IF_ID)
    );

    Data_HazardDetection U_Data_HazardDetection(
        //input
        .rR1_ID(inst_ID[19:15]),
        .rR2_ID(inst_ID[24:20]),
        .read_rD1(read_rD1),
        .read_rD2(read_rD2),
        
        .rf_wsel(rf_wsel_EX),

        .wR_EX(wR_EX),
        .wR_MEM(wR_MEM),
        .wR_WB(wR_WB),

        .wD_EX(wD_EX),
        .wD_MEM(wD),
        .wD_WB(wD_WB),

        .rf_we_EX(rf_we_EX),
        .rf_we_MEM(rf_we_MEM),
        .rf_we_WB(rf_we_MEM),
        //output
        .forward_op1(forward_op1),
        .forward_op2(forward_op2),
        .rD1_forward(rD1_forward),
        .rD2_forward(rD2_forward),
        .pipeline_stop_PC(pipeline_stop_PC),
        .pipeline_stop_REG_IF_ID(pipeline_stop_REG_IF_ID),
        .flush_REG_ID_EX(flush_REG_ID_EX_Data)
    );


    // END

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = have_inst_WB/* TODO */;
    assign debug_wb_pc        = PC_WB/* TODO */;
    assign debug_wb_ena       = rf_we_WB/* TODO */;
    assign debug_wb_reg       = wR_WB/* TODO */;
    assign debug_wb_value     = wD_WB/* TODO */;
`endif

endmodule
