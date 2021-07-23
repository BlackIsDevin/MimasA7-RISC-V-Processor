/**
    This modules implements the ID/EXE pipeline register in our pipelined
        RV64 CPU. This is effectively just an array of D flip flops.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {5} rd: 5-bit input for destination register address
    @param {64} dpc: 64-bit input for instruction's program counter value
    @param {64} qa: 64-bit input for rs1 register value
    @param {64} qb: 64-bit input for rs2 register value
    @param {64} imm64: 64-bit input for immediate value
    @param {1} signedComp: 1-bit input for signed comparison flag
    @param {3} func3: 3-bit input for function code
    @param {1} aSel: 1-bit input for ALU a-value selection
    @param {2} bSel: 1-bit input for ALU b-value selection
    @param {4} aluc: 4-bit input for ALU control
    @param {1} rSel: 1-bit input for ALU result selection
    @param {1} wmem: 1-bit input for memory-write flag
    @param {1} m2reg: 1-bit input for WB Mux select flag
    @param {1} wreg: 1-bit input for register-write flag
    @param {3} bType: 3-bit input for branch type
    @param {1} clk: 1-bit input for clock signal

    @param {5} erd: 5-bit output for destination register address
    @param {64} epc: 64-bit output for instruction's program counter value
    @param {64} eqa: 64-bit output for rs1 register value
    @param {64} eqb: 64-bit output for rs2 register value
    @param {64} eimm64: 64-bit output for immediate value
    @param {1} esignedComp: 1-bit output for signed comparison flag
    @param {3} efunc3: 3-bit output for function code
    @param {1} eaSel: 1-bit output for ALU a-value selection
    @param {2} ebSel: 1-bit output for ALU b-value selection
    @param {4} ealuc: 4-bit output for ALU control
    @param {1} erSel: 1-bit output for ALU result selection
    @param {1} ewmem: 1-bit output for memory-write flag
    @param {1} em2reg: 1-bit output for WB Mux select flag
    @param {1} ewreg: 1-bit output for register-write flag
    @param {3} ebType: 3-bit output for branch type
*/

module PipelineRegIDEXE (
    input [4:0] rd,
    input [63:0] dpc,
    input [63:0] qa,
    input [63:0] qb,
    input [63:0] imm64,
    input signedComp,
    input [2:0] func3,
    input aSel,
    input [1:0] bSel,
    input [3:0] aluc,
    input rSel,
    input wmem,
    input m2reg,
    input wreg,
    input [2:0] bType,
    input clk,

    output reg [4:0] erd,
    output reg [63:0] epc,
    output reg [63:0] eqa,
    output reg [63:0] eqb,
    output reg [63:0] eimm64,
    output reg signedComp,
    output reg [2:0] efunc3,
    output reg eaSel,
    output reg [1:0] ebSel,
    output reg [3:0] ealuc,
    output reg erSel,
    output reg ewmem,
    output reg em2reg,
    output reg ewreg,
    output reg [2:0] ebType
);

    always @(posedge clk) begin
        erd <= rd;
        epc <= dpc;
        eqa <= qa;
        eqb <= qb;
        eimm64 <= imm64;
        esignedComp <= signedComp;
        efunc3 <= func3;
        eaSel <= aSel;
        ebSel <= bSel;
        ealuc <= aluc;
        erSel <= rSel;
        ewmem <= wmem;
        em2reg <= m2reg;
        ewreg <= wreg;
        ebType <= bType;
    end

endmodule