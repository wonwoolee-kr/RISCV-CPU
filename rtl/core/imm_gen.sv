`timescale 1ns/1ps

module imm_gen
    import rv32i_pkg::*;
(
    input  logic [INST_WIDTH-1:0]       instr_i,
    input  logic [IMM_SEL_WIDTH-1:0]    imm_sel_i,

    output logic [XLEN-1:0]             imm_o
);
    always_comb begin : gen_decode
        imm_o = '0;

        case(imm_sel_i)
            IMM_I: begin
                imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:20]};
            end

            IMM_S: begin
                imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end

            IMM_B: begin
                imm_o = {{(XLEN-13){instr_i[31]}}, instr_i[31], instr_i[7],
                instr_i[30:25], instr_i[11:8], 1'b0};
            end

            default: begin
                imm_o = '0;
            end
        endcase
    end

endmodule