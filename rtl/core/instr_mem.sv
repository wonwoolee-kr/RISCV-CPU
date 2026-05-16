`timescale 1ns/1ps

module instr_mem
    import rv32i_pkg::*;
#(
    parameter int    IMEM_DEPTH = 256,
    parameter string HEX_FILE   = ""
)
(
    input  logic [XLEN-1:0]       addr_i,
    output logic [INST_WIDTH-1:0] instr_o
);

    localparam int IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH);

    logic [INST_WIDTH-1:0] mem [0:IMEM_DEPTH-1];
    logic [IMEM_ADDR_WIDTH-1:0] word_addr;

    integer i;

    initial begin
        for (i = 0; i < IMEM_DEPTH; i = i + 1) begin
            mem[i] = '0;
        end

        if (HEX_FILE != "") begin
            $readmemh(HEX_FILE, mem);
        end
    end

    assign word_addr = addr_i[IMEM_ADDR_WIDTH+1:2];
    assign instr_o   = mem[word_addr];

endmodule