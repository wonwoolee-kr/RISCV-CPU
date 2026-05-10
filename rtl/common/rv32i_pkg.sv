package rv32i_pkg;

    parameter int XLEN = 32;                // RISC-V integer register width
    parameter int ALU_OP_WIDTH = 4;         // ALU control signal width

    localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_SUB = 4'd1;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_AND = 4'd2;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_OR  = 4'd3;
    localparam logic [ALU_OP_WIDTH-1:0] ALU_XOR = 4'd4;

endpackage