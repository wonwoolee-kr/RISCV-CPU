`timescale 1ns/1ps

module pc
    import rv32i_pkg::*;
(
    input  logic              clk_i,
    input  logic              rst_ni,
    input  logic              pc_en_i,

    input  logic [XLEN-1:0]   next_pc_i,
    output logic [XLEN-1:0]   pc_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_o <= '0;
        end else begin
            if (pc_en_i) begin
                pc_o <= next_pc_i;
            end
        end
    end

endmodule

