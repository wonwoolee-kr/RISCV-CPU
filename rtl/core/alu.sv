`timescale 1ns/1ps

module alu
    import rv32i_pkg::*;
(
    input   logic [XLEN-1:0]         a_i,
    input   logic [XLEN-1:0]         b_i,
    input   logic [ALU_OP_WIDTH-1:0] alu_op_i,

    output  logic [XLEN-1:0]         result_o,
    output  logic                    zero_o
);

    always_comb begin                               // clock 없는 combination logic
        result_o = '0;

        case (alu_op_i)
            ALU_ADD : result_o = a_i + b_i;
            ALU_SUB : result_o = a_i - b_i;
            ALU_AND : result_o = a_i & b_i;
            ALU_OR  : result_o = a_i | b_i;
            ALU_XOR : result_o = a_i ^ b_i;
            default : result_o = '0;
        endcase
        
    end

    assign zero_o = (result_o == '0);
    
endmodule