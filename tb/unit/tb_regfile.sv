`timescale 1ns/1ps

module tb_regfile
    import rv32i_pkg::*;
();

    logic                      clk;
    logic                      rst_n;

    logic                      we;
    logic [REG_ADDR_WIDTH-1:0] waddr;
    logic [XLEN-1:0]           wdata;

    logic [REG_ADDR_WIDTH-1:0] raddr1;
    logic [REG_ADDR_WIDTH-1:0] raddr2;
    logic [XLEN-1:0]           rdata1;
    logic [XLEN-1:0]           rdata2;

    int pass_count;
    int fail_count;

    regfile dut (
        .clk_i    (clk),
        .rst_ni   (rst_n),
        .we_i     (we),
        .waddr_i  (waddr),
        .wdata_i  (wdata),
        .raddr1_i (raddr1),
        .raddr2_i (raddr2),
        .rdata1_o (rdata1),
        .rdata2_o (rdata2)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic write_reg(                   // automatic : 각 task call이 서로 독립된 메모리 갖게함.
        input logic [REG_ADDR_WIDTH-1:0] addr,
        input logic [XLEN-1:0]           data,
        input logic                      write_enable
    );
        begin
            @(negedge clk);
            we    = write_enable;
            waddr = addr;
            wdata = data;

            @(posedge clk);
            #1;

            we    = 1'b0;
            waddr = '0;
            wdata = '0;
        end
    endtask

    task automatic check_read(
        input logic [REG_ADDR_WIDTH-1:0] addr1,
        input logic [REG_ADDR_WIDTH-1:0] addr2,
        input logic [XLEN-1:0]           expected1,
        input logic [XLEN-1:0]           expected2,
        input string                     test_name
    );
        begin
            raddr1 = addr1;
            raddr2 = addr2;
            #1;

            if ((rdata1 === expected1) && (rdata2 === expected2)) begin
                $display("[PASS] %s: rdata1 = 0x%08h, rdata2 = 0x%08h",
                         test_name, rdata1, rdata2);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", test_name);
                $display("       expected1 = 0x%08h, rdata1 = 0x%08h", expected1, rdata1);
                $display("       expected2 = 0x%08h, rdata2 = 0x%08h", expected2, rdata2);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/wave/tb_regfile.vcd");
        $dumpvars(0, tb_regfile);

        pass_count = 0;
        fail_count = 0;

        rst_n  = 1'b0;
        we     = 1'b0;
        waddr  = '0;
        wdata  = '0;
        raddr1 = '0;
        raddr2 = '0;

        $display("========================================");
        $display(" Register File Test Start");
        $display("========================================");

        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        #1;

        check_read(5'd0, 5'd1, 32'h0000_0000, 32'h0000_0000, "After reset, x0 and x1 are zero");

        write_reg(5'd1, 32'h1234_5678, 1'b1);
        check_read(5'd1, 5'd0, 32'h1234_5678, 32'h0000_0000, "Write and read x1, x0 remains zero");

        write_reg(5'd2, 32'hDEAD_BEEF, 1'b1);
        check_read(5'd1, 5'd2, 32'h1234_5678, 32'hDEAD_BEEF, "Two read ports read x1 and x2");

        write_reg(5'd0, 32'hFFFF_FFFF, 1'b1);
        check_read(5'd0, 5'd1, 32'h0000_0000, 32'h1234_5678, "Write to x0 is ignored");

        write_reg(5'd1, 32'hAAAA_5555, 1'b0);
        check_read(5'd1, 5'd2, 32'h1234_5678, 32'hDEAD_BEEF, "Write disabled keeps previous values");

        write_reg(5'd1, 32'hAAAA_5555, 1'b1);
        check_read(5'd1, 5'd2, 32'hAAAA_5555, 32'hDEAD_BEEF, "Overwrite x1");

        $display("========================================");
        $display(" Register File Test Summary");
        $display(" PASS: %0d", pass_count);
        $display(" FAIL: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("REGISTER FILE TEST PASSED");
        end else begin
            $display("REGISTER FILE TEST FAILED (Total Fails: %0d)", fail_count);
        end

        $finish;
    end

endmodule
