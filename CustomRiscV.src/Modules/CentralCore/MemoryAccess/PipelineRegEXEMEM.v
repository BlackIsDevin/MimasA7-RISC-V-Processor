/**
    This modules implements the EXE/MEM pipeline register in our pipelined
        RV64 CPU. This is effectively just an array of D flip flops.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {5} erd: 5-bit input for destination register address
    @param {64} er: 64-bit input for execution result
    @param {64} eqb: 64-bit input for rs2 register value
    @param {1} ewmem: 1-bit input for memory-write flag
    @param {3} efunc3: 3-bit input for function code
    @param {1} em2reg: 1-bit input for WB Mux select flag
    @param {1} ewreg: 1-bit input for register-write flag
    @param {1} clk: 1-bit input for clock signal

    @param {5} mrd: 5-bit output for destination register address
    @param {64} mr: 64-bit output for execution result
    @param {64} mqb: 64-bit output for rs2 register value
    @param {1} mwmem: 1-bit output for memory-write flag
    @param {3} mfunc3: 3-bit output for function code
    @param {1} mm2reg: 1-bit output for WB Mux select flag
    @param {1} mwreg: 1-bit output for register-write flag
*/

module PipelineRegEXEMEM (
    input [4:0] erd,
    input [63:0] er, eqb,
    input ewmem,
    input [2:0] efunc3,
    input em2reg, ewreg,
    input clk,

    output reg [4:0] mrd,
    output reg [63:0] mr, mqb,
    output reg mwmem,
    output reg [2:0] mfunc3,
    output reg mm2reg, mwreg
);

    always @(posedge clk) begin
        mrd <= erd;
        mr <= er;
        mqb <= eqb;
        mwmem <= ewmem;
        mfunc3 <= efunc3;
        mm2reg <= em2reg;
        mwreg <= ewreg;
    end

endmodule