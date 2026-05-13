`timescale 1ns/1ps

module decoder
    import rv32i_pkg::*;
(
    input  logic [INST_WIDTH-1:0]        instr_i,

    output logic [REG_ADDR_WIDTH-1:0]    rs1_addr_o,
    output logic [REG_ADDR_WIDTH-1:0]    rs2_addr_o,
    output logic [REG_ADDR_WIDTH-1:0]    rd_addr_o,

    output logic [ALU_OP_WIDTH-1:0]      alu_op_o,
    output logic [IMM_SEL_WIDTH-1:0]     imm_sel_o,

    output logic                         is_r_type_o,
    output logic                         is_op_imm_o,
    output logic                         is_load_o,
    output logic                         is_store_o,
    output logic                         is_branch_o,

    output logic                         instr_valid_o
);

    logic [OPCODE_WIDTH-1:0] opcode;
    logic [FUNCT3_WIDTH-1:0] funct3;
    logic [FUNCT7_WIDTH-1:0] funct7;

    logic [REG_ADDR_WIDTH-1:0] rs1_raw;
    logic [REG_ADDR_WIDTH-1:0] rs2_raw;
    logic [REG_ADDR_WIDTH-1:0] rd_raw;

    assign opcode = instr_i[6:0];
    assign rd_raw = instr_i[11:7];
    assign funct3 = instr_i[14:12];
    assign rs1_raw = instr_i[19:15];
    assign rs2_raw = instr_i[24:20];
    assign funct7 = instr_i[31:25];

    always_comb begin
        rs1_addr_o    = '0;
        rs2_addr_o    = '0;
        rd_addr_o     = '0;

        alu_op_o      = ALU_ADD;
        imm_sel_o     = IMM_NONE;

        is_r_type_o   = 1'b0;
        is_op_imm_o   = 1'b0;
        is_load_o     = 1'b0;
        is_store_o    = 1'b0;
        is_branch_o   = 1'b0;

        instr_valid_o = 1'b0;

        case (opcode)
            OPCODE_OP: begin
                is_r_type_o = 1'b1;

                rs1_addr_o = rs1_raw;
                rs2_addr_o = rs2_raw;
                rd_addr_o  = rd_raw;
                imm_sel_o  = IMM_NONE;

                case (funct3)
                    FUNCT3_ADD_SUB: begin
                        if (funct7 == FUNCT7_ADD) begin
                            alu_op_o = ALU_ADD;
                            instr_valid_o = 1'b1;
                        end else if (funct7 == FUNCT7_SUB) begin
                            alu_op_o = ALU_SUB;
                            instr_valid_o = 1'b1;
                        end
                    end

                    FUNCT3_AND: begin
                        if (funct7 == FUNCT7_ADD) begin
                            alu_op_o = ALU_AND;
                            instr_valid_o = 1'b1;
                        end
                    end

                    FUNCT3_OR: begin
                        if (funct7 == FUNCT7_ADD) begin
                            alu_op_o = ALU_OR;
                            instr_valid_o = 1'b1;
                        end
                    end

                    FUNCT3_XOR: begin
                        if (funct7 == FUNCT7_ADD) begin
                            alu_op_o = ALU_XOR;
                            instr_valid_o = 1'b1;
                        end
                    end

                    default: begin
                        instr_valid_o = 1'b0;
                    end
                endcase
            end

            OPCODE_OP_IMM: begin
                is_op_imm_o = 1'b1;

                rs1_addr_o = rs1_raw;
                rs2_addr_o = '0;
                rd_addr_o  = rd_raw;
                imm_sel_o  = IMM_I;

                if (funct3 == FUNCT3_ADDI) begin
                    alu_op_o = ALU_ADD;
                    instr_valid_o = 1'b1;
                end
            end

            OPCODE_LOAD: begin
                is_load_o = 1'b1;

                rs1_addr_o = rs1_raw;
                rs2_addr_o = '0;
                rd_addr_o  = rd_raw;
                imm_sel_o  = IMM_I;

                if (funct3 == FUNCT3_LW_SW) begin
                    alu_op_o = ALU_ADD;
                    instr_valid_o = 1'b1;
                end
            end

            OPCODE_STORE: begin
                is_store_o = 1'b1;

                rs1_addr_o = rs1_raw;
                rs2_addr_o = rs2_raw;
                rd_addr_o  = '0;
                imm_sel_o  = IMM_S;

                if (funct3 == FUNCT3_LW_SW) begin
                    alu_op_o = ALU_ADD;
                    instr_valid_o = 1'b1;
                end
            end

            OPCODE_BRANCH: begin
                is_branch_o = 1'b1;

                rs1_addr_o = rs1_raw;
                rs2_addr_o = rs2_raw;
                rd_addr_o  = '0;
                imm_sel_o  = IMM_B;

                if (funct3 == FUNCT3_BEQ) begin
                    alu_op_o = ALU_SUB;
                    instr_valid_o = 1'b1;
                end
            end

            default: begin
                instr_valid_o = 1'b0;
            end
        endcase
    end

endmodule