`timescale 1ns/1ps

module tb_alu
    import rv32i_pkg::*;
();

    logic [XLEN-1:0]         a;
    logic [XLEN-1:0]         b;
    logic [ALU_OP_WIDTH-1:0] alu_op;

    logic [XLEN-1:0]         result;
    logic                    zero;

    int pass_count;
    int fail_count;

    alu dut (
        .a_i      (a),
        .b_i      (b),
        .alu_op_i (alu_op),
        .result_o (result),
        .zero_o   (zero)
    );

    task automatic check_result;
        input logic [XLEN-1:0]         test_a;
        input logic [XLEN-1:0]         test_b;
        input logic [ALU_OP_WIDTH-1:0] test_op;
        input logic [XLEN-1:0]         expected;
        input string                   test_name;

        begin
            a      = test_a;
            b      = test_b;
            alu_op = test_op;

            #1;

            if (result === expected) begin          //Case Equality 보장 >> ===로 모든 비트가 일치한지 확인 cf, ==는 X, Z가 발생한 경우에 대해 Logical Equality만 보장.
                $display("[PASS] %s: result = 0x%08h", test_name, result);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: expected = 0x%08h, result = 0x%08h",
                         test_name, expected, result);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_alu.vcd");
        $dumpvars(0, tb_alu);               // 0: all sub signals, 1: top signals, 2: 지정한 모듈  + 바로 아래 단계의 하위 모듈까지 기록

        pass_count = 0;
        fail_count = 0;

        $display("========================================");
        $display(" ALU Test Start");
        $display("========================================");

        check_result(32'd10,        32'd20,        ALU_ADD, 32'd30,        "ADD 10 + 20");
        check_result(32'd20,        32'd10,        ALU_SUB, 32'd10,        "SUB 20 - 10");
        check_result(32'hF0F0_0000, 32'h0F0F_0000, ALU_AND, 32'h0000_0000, "AND");
        check_result(32'hF0F0_0000, 32'h0F0F_0000, ALU_OR,  32'hFFFF_0000, "OR");
        check_result(32'hAAAA_5555, 32'hFFFF_0000, ALU_XOR, 32'h5555_5555, "XOR");

        check_result(32'd5,         32'd5,         ALU_SUB, 32'd0,         "ZERO flag input");

        if (zero === 1'b1) begin
            $display("[PASS] ZERO flag");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] ZERO flag: expected = 1, zero = %0b", zero);
            fail_count = fail_count + 1;
        end

        $display("========================================");
        $display(" ALU Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("ALU TEST PASSED");
        end else begin
            $display("ALU TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule
