/**
    This module implements the register file for our RISC-V processor. The
        register file holds the 32 general purpose registers for our processor.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {5} rs1: input for register 1
    @param {5} rs2: input for register 2
    @param {5} wrd: writeback register destination
    @param {64} wbd: writeback data
    @param {1} wwreg: regfile write enable
    @param {1} clk: input clock signal 
    
    @param {64} rqa: output for register 1
    @param {64} rqb: output for register 2
*/

module RegisterFile (
    input [4:0] rs1, rs2, wrd,
    input [63:0] wbd,
    input wwreg, clk,

    output reg [63:0] rqa, rqb
);

    reg [63:0] regfile [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regfile [i] = 64'h0;
    end

    always @(negedge clk) begin
        if (wwreg & (wrd != 0))
            regfile[wrd] <= wbd;
    end

    always @(*) begin
        rqa = regfile[rs1];
        rqb = regfile[rs2];
    end

endmodule
