package rv32i_pkg;

    parameter int XLEN = 32;                // RISC-V integer register width
    parameter int INST_WIDTH = 32;          // RISC-V base instruction width
    parameter int ALU_OP_WIDTH = 4;         // ALU control signal width

    parameter int REG_COUNT = 32;           // Number of integer registers
    parameter int REG_ADDR_WIDTH = 5;       // log2_REG_Count, used for rs,rd

    parameter int IMM_SEL_WIDTH = 3;        // Immediate type select signal width

    parameter int OPCODE_WIDTH = 7;         // RISC-V opcode width
    parameter int FUNCT3_WIDTH = 3;         // RISC-V funct3 width
    parameter int FUNCT7_WIDTH = 7;         // RISC-V funct7 width

    // ALU localparam
    localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_SUB = 4'd1;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_AND = 4'd2;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_OR  = 4'd3;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_XOR = 4'd4;

    // IMM_GEN localparam
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_I      = 3'd0;
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_S      = 3'd1;
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_B      = 3'd2;      // also called IMM_SB in Patterson & Hennessy
    localparam logic [IMM_SEL_WIDTH-1:0] IMM_NONE   = 3'd7;


    // RISC-V opcode values
    localparam logic [OPCODE_WIDTH-1:0] OPCODE_OP     = 7'b0110011; // R-type register-register operation
    localparam logic [OPCODE_WIDTH-1:0] OPCODE_OP_IMM = 7'b0010011; // I-type ALU immediate operation
    localparam logic [OPCODE_WIDTH-1:0] OPCODE_LOAD   = 7'b0000011; // Load instruction
    localparam logic [OPCODE_WIDTH-1:0] OPCODE_STORE  = 7'b0100011; // Store instruction
    localparam logic [OPCODE_WIDTH-1:0] OPCODE_BRANCH = 7'b1100011; // Branch instruction

    // funct3 values
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_ADD_SUB = 3'b000;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_ADDI    = 3'b000;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_XOR     = 3'b100;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_OR      = 3'b110;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_AND     = 3'b111;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_LW_SW   = 3'b010;
    localparam logic [FUNCT3_WIDTH-1:0] FUNCT3_BEQ     = 3'b000;

    // funct7 values for R-type ADD/SUB
    localparam logic [FUNCT7_WIDTH-1:0] FUNCT7_ADD = 7'b0000000;
    localparam logic [FUNCT7_WIDTH-1:0] FUNCT7_SUB = 7'b0100000;
endpackage