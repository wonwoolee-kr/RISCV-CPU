`timescale 1ns/1ps

module tb_decoder
    import rv32i_pkg::*;
();

    logic [INST_WIDTH-1:0]        instr;

    logic [REG_ADDR_WIDTH-1:0]    rs1_addr;
    logic [REG_ADDR_WIDTH-1:0]    rs2_addr;
    logic [REG_ADDR_WIDTH-1:0]    rd_addr;

    logic [ALU_OP_WIDTH-1:0]      alu_op;
    logic [IMM_SEL_WIDTH-1:0]     imm_sel;

    logic                         is_r_type;
    logic                         is_op_imm;
    logic                         is_load;
    logic                         is_store;
    logic                         is_branch;

    logic                         instr_valid;

    int pass_count;
    int fail_count;

    decoder dut (
        .instr_i       (instr),

        .rs1_addr_o    (rs1_addr),
        .rs2_addr_o    (rs2_addr),
        .rd_addr_o     (rd_addr),

        .alu_op_o      (alu_op),
        .imm_sel_o     (imm_sel),

        .is_r_type_o   (is_r_type),
        .is_op_imm_o   (is_op_imm),
        .is_load_o     (is_load),
        .is_store_o    (is_store),
        .is_branch_o   (is_branch),

        .instr_valid_o (instr_valid)
    );

    function automatic logic [31:0] make_r_type_instr(
        input logic [FUNCT7_WIDTH-1:0]       funct7,
        input logic [REG_ADDR_WIDTH-1:0]     rs2,
        input logic [REG_ADDR_WIDTH-1:0]     rs1,
        input logic [FUNCT3_WIDTH-1:0]       funct3,
        input logic [REG_ADDR_WIDTH-1:0]     rd,
        input logic [OPCODE_WIDTH-1:0]       opcode
    );
        logic [31:0] temp;
        begin
            temp = '0;
            temp[31:25] = funct7;
            temp[24:20] = rs2;
            temp[19:15] = rs1;
            temp[14:12] = funct3;
            temp[11:7]  = rd;
            temp[6:0]   = opcode;
            return temp;
        end
    endfunction

    function automatic logic [31:0] make_i_type_instr(
        input logic [11:0]                   imm12,
        input logic [REG_ADDR_WIDTH-1:0]     rs1,
        input logic [FUNCT3_WIDTH-1:0]       funct3,
        input logic [REG_ADDR_WIDTH-1:0]     rd,
        input logic [OPCODE_WIDTH-1:0]       opcode
    );
        logic [31:0] temp;
        begin
            temp = '0;
            temp[31:20] = imm12;
            temp[19:15] = rs1;
            temp[14:12] = funct3;
            temp[11:7]  = rd;
            temp[6:0]   = opcode;
            return temp;
        end
    endfunction

    function automatic logic [31:0] make_s_type_instr(
        input logic [11:0]                   imm12,
        input logic [REG_ADDR_WIDTH-1:0]     rs2,
        input logic [REG_ADDR_WIDTH-1:0]     rs1,
        input logic [FUNCT3_WIDTH-1:0]       funct3,
        input logic [OPCODE_WIDTH-1:0]       opcode
    );
        logic [31:0] temp;
        begin
            temp = '0;
            temp[31:25] = imm12[11:5];
            temp[24:20] = rs2;
            temp[19:15] = rs1;
            temp[14:12] = funct3;
            temp[11:7]  = imm12[4:0];
            temp[6:0]   = opcode;
            return temp;
        end
    endfunction

    function automatic logic [31:0] make_b_type_instr(
        input logic [12:0]                   imm13,
        input logic [REG_ADDR_WIDTH-1:0]     rs2,
        input logic [REG_ADDR_WIDTH-1:0]     rs1,
        input logic [FUNCT3_WIDTH-1:0]       funct3,
        input logic [OPCODE_WIDTH-1:0]       opcode
    );
        logic [31:0] temp;
        begin
            temp = '0;
            temp[31]    = imm13[12];
            temp[7]     = imm13[11];
            temp[30:25] = imm13[10:5];
            temp[24:20] = rs2;
            temp[19:15] = rs1;
            temp[14:12] = funct3;
            temp[11:8]  = imm13[4:1];
            temp[6:0]   = opcode;
            return temp;
        end
    endfunction

    task automatic check_decode;
        input logic [31:0]                   test_instr;

        input logic [REG_ADDR_WIDTH-1:0]     exp_rs1;
        input logic [REG_ADDR_WIDTH-1:0]     exp_rs2;
        input logic [REG_ADDR_WIDTH-1:0]     exp_rd;

        input logic [ALU_OP_WIDTH-1:0]       exp_alu_op;
        input logic [IMM_SEL_WIDTH-1:0]      exp_imm_sel;

        input logic                          exp_r_type;
        input logic                          exp_op_imm;
        input logic                          exp_load;
        input logic                          exp_store;
        input logic                          exp_branch;
        input logic                          exp_valid;

        input string                         test_name;

        begin
            instr = test_instr;
            #1;

            if ((rs1_addr    === exp_rs1)     &&
                (rs2_addr    === exp_rs2)     &&
                (rd_addr     === exp_rd)      &&
                (alu_op      === exp_alu_op)  &&
                (imm_sel     === exp_imm_sel) &&
                (is_r_type   === exp_r_type)  &&
                (is_op_imm   === exp_op_imm)  &&
                (is_load     === exp_load)    &&
                (is_store    === exp_store)   &&
                (is_branch   === exp_branch)  &&
                (instr_valid === exp_valid)) begin

                $display("[PASS] %s", test_name);
                pass_count = pass_count + 1;

            end else begin
                $display("[FAIL] %s", test_name);
                $display("       rs1 expected=%0d actual=%0d", exp_rs1, rs1_addr);
                $display("       rs2 expected=%0d actual=%0d", exp_rs2, rs2_addr);
                $display("       rd  expected=%0d actual=%0d", exp_rd, rd_addr);
                $display("       alu_op expected=0x%0h actual=0x%0h", exp_alu_op, alu_op);
                $display("       imm_sel expected=0x%0h actual=0x%0h", exp_imm_sel, imm_sel);
                $display("       flags expected R=%0b I=%0b L=%0b S=%0b B=%0b V=%0b",
                         exp_r_type, exp_op_imm, exp_load, exp_store, exp_branch, exp_valid);
                $display("       flags actual   R=%0b I=%0b L=%0b S=%0b B=%0b V=%0b",
                         is_r_type, is_op_imm, is_load, is_store, is_branch, instr_valid);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_decoder.vcd");
        $dumpvars(0, tb_decoder);

        pass_count = 0;
        fail_count = 0;

        instr = '0;

        $display("========================================");
        $display(" Decoder Test Start");
        $display("========================================");

        check_decode(
            make_r_type_instr(FUNCT7_ADD, 5'd2, 5'd1, FUNCT3_ADD_SUB, 5'd3, OPCODE_OP),
            5'd1, 5'd2, 5'd3,
            ALU_ADD, IMM_NONE,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            "R-type ADD"
        );

        check_decode(
            make_r_type_instr(FUNCT7_SUB, 5'd2, 5'd1, FUNCT3_ADD_SUB, 5'd3, OPCODE_OP),
            5'd1, 5'd2, 5'd3,
            ALU_SUB, IMM_NONE,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            "R-type SUB"
        );

        check_decode(
            make_r_type_instr(FUNCT7_ADD, 5'd2, 5'd1, FUNCT3_AND, 5'd3, OPCODE_OP),
            5'd1, 5'd2, 5'd3,
            ALU_AND, IMM_NONE,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            "R-type AND"
        );

        check_decode(
            make_r_type_instr(FUNCT7_ADD, 5'd2, 5'd1, FUNCT3_OR, 5'd3, OPCODE_OP),
            5'd1, 5'd2, 5'd3,
            ALU_OR, IMM_NONE,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            "R-type OR"
        );

        check_decode(
            make_r_type_instr(FUNCT7_ADD, 5'd2, 5'd1, FUNCT3_XOR, 5'd3, OPCODE_OP),
            5'd1, 5'd2, 5'd3,
            ALU_XOR, IMM_NONE,
            1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1,
            "R-type XOR"
        );

        check_decode(
            make_i_type_instr(12'd10, 5'd1, FUNCT3_ADDI, 5'd3, OPCODE_OP_IMM),
            5'd1, 5'd0, 5'd3,
            ALU_ADD, IMM_I,
            1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1,
            "I-type ADDI"
        );

        check_decode(
            make_i_type_instr(12'd0, 5'd1, FUNCT3_LW_SW, 5'd3, OPCODE_LOAD),
            5'd1, 5'd0, 5'd3,
            ALU_ADD, IMM_I,
            1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1,
            "Load LW"
        );

        check_decode(
            make_s_type_instr(12'd8, 5'd3, 5'd1, FUNCT3_LW_SW, OPCODE_STORE),
            5'd1, 5'd3, 5'd0,
            ALU_ADD, IMM_S,
            1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1,
            "Store SW"
        );

        check_decode(
            make_b_type_instr(13'd8, 5'd2, 5'd1, FUNCT3_BEQ, OPCODE_BRANCH),
            5'd1, 5'd2, 5'd0,
            ALU_SUB, IMM_B,
            1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1,
            "Branch BEQ"
        );

        check_decode(
            32'h0000_0000,
            5'd0, 5'd0, 5'd0,
            ALU_ADD, IMM_NONE,
            1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
            "Invalid opcode"
        );

        $display("========================================");
        $display(" Decoder Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("DECODER TEST PASSED");
        end else begin
            $display("DECODER TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule