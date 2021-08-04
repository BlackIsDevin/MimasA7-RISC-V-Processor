/**
    This modules implements the MEM/WB pipeline register in our pipelined
        RV64 CPU. This is effectively just an array of D flip flops.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {5} mrd: 5-bit input for destination register address
    @param {64} mr: 64-bit input for execution result
    @param {64} md: 64-bit input for data memory output
    @param {1} mm2reg: 1-bit input for WB Mux select flag
    @param {1} mwreg: 1-bit input for register-write flag
    @param {1} clk: 1-bit input for clock signal

    @param {5} wrd: 5-bit output for destination register address
    @param {64} wr: 64-bit output for execution result
    @param {64} wd: 64-bit output for data memory output
    @param {1} wm2reg: 1-bit output for WB Mux select flag
    @param {1} wwreg: 1-bit output for register-write flag
*/

module PipelineRegMEMWB (
    input [4:0] mrd,
    input [63:0] mr,
    input [63:0] md,
    input mm2reg,
    input mwreg,
    input clk,

    output reg [4:0] wrd,
    output reg [63:0] wr,
    output reg [63:0] wd,
    output reg wm2reg,
    output reg wwreg
);

    always @(posedge clk) begin
        wrd <= mrd;
        wr <= mr;
        wd <= md;
        wm2reg <= mm2reg;
        wwreg <= mwreg;
    end

endmodule