`timescale 1ns/1ps

module regfile
    import rv32i_pkg::*;
(
    input  logic                       clk_i,
    input  logic                       rst_ni,

    input  logic                       we_i,
    input  logic [REG_ADDR_WIDTH-1:0]  waddr_i,
    input  logic [XLEN-1:0]            wdata_i,

    input  logic [REG_ADDR_WIDTH-1:0]  raddr1_i,
    input  logic [REG_ADDR_WIDTH-1:0]  raddr2_i,

    output logic [XLEN-1:0]            rdata1_o,
    output logic [XLEN-1:0]            rdata2_o
);

    logic [XLEN-1:0] rf [0:REG_COUNT-1];

    integer i;

    always_ff @(posedge clk_i or negedge rst_ni)
    begin
        if (!rst_ni) begin
            for (i = 0; i < REG_COUNT; i = i + 1) begin
                rf[i] <= '0;
            end
        end
        else begin
            if (we_i && (waddr_i != '0)) begin
                rf[waddr_i] <= wdata_i;
            end
        end
    end

    assign rdata1_o = (raddr1_i == '0) ? '0 : rf[raddr1_i];
    assign rdata2_o = (raddr2_i == '0) ? '0 : rf[raddr2_i];

endmodule