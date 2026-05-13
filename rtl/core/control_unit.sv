`timescale 1ns/1ps

module control_unit
    import rv32i_pkg::*;
(
    input  logic                         is_r_type_i,
    input  logic                         is_op_imm_i,
    input  logic                         is_load_i,
    input  logic                         is_store_i,
    input  logic                         is_branch_i,
    input  logic                         instr_valid_i,

    output logic                         reg_write_o,       // 1 when R-Type, ADDI, LW
    output logic                         alu_src_o,         // 1 when immediate rsc
    output logic                         mem_read_o,        // 1 when LW
    output logic                         mem_write_o,       // 1 when SW
    output logic                         branch_o,          // 1 when branch
    output logic [WB_SEL_WIDTH-1:0]      wb_sel_o           // select writeback data src
);

    always_comb begin
        reg_write_o = 1'b0;
        alu_src_o   = 1'b0;
        mem_read_o  = 1'b0;
        mem_write_o = 1'b0;
        branch_o    = 1'b0;
        wb_sel_o    = WB_NONE;

        if (instr_valid_i) begin
            if (is_r_type_i) begin
                reg_write_o = 1'b1;
                alu_src_o   = 1'b0;
                mem_read_o  = 1'b0;
                mem_write_o = 1'b0;
                branch_o    = 1'b0;
                wb_sel_o    = WB_ALU;
            end else if (is_op_imm_i) begin
                reg_write_o = 1'b1;
                alu_src_o   = 1'b1;
                mem_read_o  = 1'b0;
                mem_write_o = 1'b0;
                branch_o    = 1'b0;
                wb_sel_o    = WB_ALU;
            end else if (is_load_i) begin
                reg_write_o = 1'b1;
                alu_src_o   = 1'b1;
                mem_read_o  = 1'b1;
                mem_write_o = 1'b0;
                branch_o    = 1'b0;
                wb_sel_o    = WB_MEM;
            end else if (is_store_i) begin
                reg_write_o = 1'b0;
                alu_src_o   = 1'b1;
                mem_read_o  = 1'b0;
                mem_write_o = 1'b1;
                branch_o    = 1'b0;
                wb_sel_o    = WB_NONE;
            end else if (is_branch_i) begin
                reg_write_o = 1'b0;
                alu_src_o   = 1'b0;
                mem_read_o  = 1'b0;
                mem_write_o = 1'b0;
                branch_o    = 1'b1;
                wb_sel_o    = WB_NONE;
            end
        end
    end

endmodule