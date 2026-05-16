`timescale 1ns/1ps

module tb_fetch
    import rv32i_pkg::*;
();

    logic             clk;
    logic             rst_n;
    logic             pc_en;

    logic [XLEN-1:0]  pc;
    logic [XLEN-1:0]  next_pc;
    logic [31:0]      instr;

    int pass_count;
    int fail_count;

    pc u_pc (
        .clk_i     (clk),
        .rst_ni    (rst_n),
        .pc_en_i   (pc_en),
        .next_pc_i (next_pc),
        .pc_o      (pc)
    );

    instr_mem #(
        .IMEM_DEPTH (256),
        .HEX_FILE   ("sim/hex/fetch_test.hex")
    ) u_instr_mem (
        .addr_i  (pc),
        .instr_o (instr)
    );

    assign next_pc = pc + 32'd4;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic check_fetch;
        input logic [XLEN-1:0] expected_pc;
        input logic [31:0]     expected_instr;
        input string           test_name;

        begin
            if ((pc === expected_pc) && (instr === expected_instr)) begin
                $display("[PASS] %s: pc = 0x%08h, instr = 0x%08h",
                         test_name, pc, instr);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", test_name);
                $display("       expected pc    = 0x%08h, actual pc    = 0x%08h",
                         expected_pc, pc);
                $display("       expected instr = 0x%08h, actual instr = 0x%08h",
                         expected_instr, instr);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_fetch.vcd");
        $dumpvars(0, tb_fetch);

        pass_count = 0;
        fail_count = 0;

        pc_en = 1'b1;

        rst_n = 1'b1;
        #1;
        rst_n = 1'b0;
        #1;

        $display("========================================");
        $display(" Fetch Stage Test Start");
        $display("========================================");

        check_fetch(32'h0000_0000, 32'h0050_0093, "Reset PC and fetch instruction 0");

        @(posedge clk);
        #1;

        rst_n = 1'b1;
        #1;

        check_fetch(32'h0000_0000, 32'h0050_0093, "Fetch instruction at PC 0");

        @(posedge clk);
        #1;
        check_fetch(32'h0000_0004, 32'h0070_0113, "Fetch instruction at PC 4");

        @(posedge clk);
        #1;
        check_fetch(32'h0000_0008, 32'h0020_81b3, "Fetch instruction at PC 8");

        @(posedge clk);
        #1;
        check_fetch(32'h0000_000c, 32'h0000_0013, "Fetch instruction at PC 12");

        $display("========================================");
        $display(" Fetch Stage Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("FETCH STAGE TEST PASSED");
        end else begin
            $display("FETCH STAGE TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule