`timescale 1ns/1ps

module tb_control_unit
    import rv32i_pkg::*;
();

    logic                    is_r_type;
    logic                    is_op_imm;
    logic                    is_load;
    logic                    is_store;
    logic                    is_branch;
    logic                    instr_valid;

    logic                    reg_write;
    logic                    alu_src;
    logic                    mem_read;
    logic                    mem_write;
    logic                    branch;
    logic [WB_SEL_WIDTH-1:0] wb_sel;

    int pass_count;
    int fail_count;

    control_unit dut (
        .is_r_type_i   (is_r_type),
        .is_op_imm_i   (is_op_imm),
        .is_load_i     (is_load),
        .is_store_i    (is_store),
        .is_branch_i   (is_branch),
        .instr_valid_i (instr_valid),

        .reg_write_o   (reg_write),
        .alu_src_o     (alu_src),
        .mem_read_o    (mem_read),
        .mem_write_o   (mem_write),
        .branch_o      (branch),
        .wb_sel_o      (wb_sel)
    );

    task automatic check_control;
        input logic                    test_is_r_type;
        input logic                    test_is_op_imm;
        input logic                    test_is_load;
        input logic                    test_is_store;
        input logic                    test_is_branch;
        input logic                    test_instr_valid;

        input logic                    exp_reg_write;
        input logic                    exp_alu_src;
        input logic                    exp_mem_read;
        input logic                    exp_mem_write;
        input logic                    exp_branch;
        input logic [WB_SEL_WIDTH-1:0] exp_wb_sel;

        input string                   test_name;

        begin
            is_r_type   = test_is_r_type;
            is_op_imm   = test_is_op_imm;
            is_load     = test_is_load;
            is_store    = test_is_store;
            is_branch   = test_is_branch;
            instr_valid = test_instr_valid;

            #1;

            if ((reg_write === exp_reg_write) &&
                (alu_src   === exp_alu_src)   &&
                (mem_read  === exp_mem_read)  &&
                (mem_write === exp_mem_write) &&
                (branch    === exp_branch)    &&
                (wb_sel    === exp_wb_sel)) begin

                $display("[PASS] %s", test_name);
                pass_count = pass_count + 1;

            end else begin
                $display("[FAIL] %s", test_name);
                $display("       reg_write expected=%0b actual=%0b", exp_reg_write, reg_write);
                $display("       alu_src   expected=%0b actual=%0b", exp_alu_src, alu_src);
                $display("       mem_read  expected=%0b actual=%0b", exp_mem_read, mem_read);
                $display("       mem_write expected=%0b actual=%0b", exp_mem_write, mem_write);
                $display("       branch    expected=%0b actual=%0b", exp_branch, branch);
                $display("       wb_sel    expected=0x%0h actual=0x%0h", exp_wb_sel, wb_sel);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        pass_count = 0;
        fail_count = 0;

        is_r_type   = 1'b0;
        is_op_imm   = 1'b0;
        is_load     = 1'b0;
        is_store    = 1'b0;
        is_branch   = 1'b0;
        instr_valid = 1'b0;

        $display("========================================");
        $display(" Control Unit Test Start");
        $display("========================================");

        check_control(
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, WB_ALU,
            "R-type control"
        );

        check_control(
            1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1,
            1'b1, 1'b1, 1'b0, 1'b0, 1'b0, WB_ALU,
            "OP-IMM control"
        );

        check_control(
            1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1,
            1'b1, 1'b1, 1'b1, 1'b0, 1'b0, WB_MEM,
            "LOAD control"
        );

        check_control(
            1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1,
            1'b0, 1'b1, 1'b0, 1'b1, 1'b0, WB_NONE,
            "STORE control"
        );

        check_control(
            1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1,
            1'b0, 1'b0, 1'b0, 1'b0, 1'b1, WB_NONE,
            "BRANCH control"
        );

        check_control(
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
            1'b0, 1'b0, 1'b0, 1'b0, 1'b0, WB_NONE,
            "Invalid instruction disables all controls"
        );

        check_control(
            1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            1'b0, 1'b0, 1'b0, 1'b0, 1'b0, WB_NONE,
            "Valid but no type flag"
        );

        $display("========================================");
        $display(" Control Unit Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("CONTROL UNIT TEST PASSED");
        end else begin
            $display("CONTROL UNIT TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule