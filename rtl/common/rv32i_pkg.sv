package rv32i_pkg;

    parameter int XLEN = 32;                // RISC-V integer register width
    parameter int INST_WIDTH = 32;          // RISC-V base instruction width
    parameter int ALU_OP_WIDTH = 4;         // ALU control signal width

    parameter int REG_COUNT = 32;           // Number of integer registers
    parameter int REG_ADDR_WIDTH = 5;       // log2_REG_Count, used for rs,rd

    parameter int IMM_SEL_WIDTH = 3;        // Immediate type select signal width

    // ALU localparam
    localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_SUB = 4'd1;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_AND = 4'd2;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_OR  = 4'd3;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_XOR = 4'd4;

    // IMM_GEN localparam
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_I = 3'd0;
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_S = 3'd1;
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_B = 3'd2;      // also called IMM_SB in Patterson & Hennessy

endpackage