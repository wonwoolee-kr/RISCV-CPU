`timescale 1ns/1ps

module tb_imm_gen
    import rv32i_pkg::*; ();

    logic [INST_WIDTH-1:0]      instr;
    logic [IMM_SEL_WIDTH-1:0]   imm_sel;
    logic [XLEN-1:0]            imm;

    int pass_count, fail_count;

    imm_gen dut (
        .instr_i    (instr),
        .imm_sel_i  (imm_sel),
        .imm_o      (imm)
    );

// --- Helper function ---

    // I Type
    function automatic logic [INST_WIDTH-1:0] make_i_type_instr(
        input logic [11:0] imm12
    );
        logic [INST_WIDTH-1:0] temp;
        begin
            temp = '0;
            temp[INST_WIDTH-1:20] = imm12;
            return temp;
        end
    endfunction

    // S Type
    function automatic logic [INST_WIDTH-1:0] make_s_type_instr(
        input logic [11:0] imm12
    );
        logic [INST_WIDTH-1:0] temp;
        begin
            temp = '0;
            temp[INST_WIDTH-1:25]   = imm12[11:5];
            temp[11:7]              = imm12[4:0];
            return temp;
        end
    endfunction

    // B Type
    function automatic logic [INST_WIDTH-1:0] make_b_type_instr(
        input logic [12:0] imm13
    );
        logic [INST_WIDTH-1:0] temp;
        begin
            temp = '0;
            temp[INST_WIDTH-1]  = imm13[12];
            temp[7]             = imm13[11];
            temp[30:25]         = imm13[10:5];
            temp[11:8]          = imm13[4:1];
            return temp;
        end
    endfunction


// --- Test Tasks ---

    task automatic check_imm(
        input logic [INST_WIDTH-1:0]    test_instr,
        input logic [IMM_SEL_WIDTH-1:0] test_sel,
        input logic [XLEN-1:0]          expected,
        input string                    test_name
    );
        begin
            instr   = test_instr;
            imm_sel = test_sel;

            #1;

            if (imm === expected) begin
                $display("[PASS] %s: imm = 0x%08h", test_name, imm);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", test_name);
                $display("       expected = 0x%08h, imm = 0x%08h", expected, imm);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);

        pass_count = 0;
        fail_count = 0;

        instr   = '0;
        imm_sel = '0;

        $display("========================================");
        $display(" Immediate Generator Test Start");
        $display("========================================");

        check_imm(make_i_type_instr(12'd5),    IMM_I, 32'h0000_0005, "I-type positive immediate +5");
        check_imm(make_i_type_instr(12'hFFF),  IMM_I, 32'hFFFF_FFFF, "I-type negative immediate -1");

        check_imm(make_s_type_instr(12'd16),   IMM_S, 32'h0000_0010, "S-type positive immediate +16");
        check_imm(make_s_type_instr(12'hFF8),  IMM_S, 32'hFFFF_FFF8, "S-type negative immediate -8");

        check_imm(make_b_type_instr(13'd8),    IMM_B, 32'h0000_0008, "B-type positive immediate +8");
        check_imm(make_b_type_instr(13'h1FFC), IMM_B, 32'hFFFF_FFFC, "B-type negative immediate -4");

        $display("========================================");
        $display(" Immediate Generator Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("IMMEDIATE GENERATOR TEST PASSED");
        end else begin
            $display("IMMEDIATE GENERATOR TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule