/**
    This modules holds the central datapath of the CPU core, as well as
        exposes parts of data memory (and in the future, a writable instruction
        memory module) to other modules.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)
    
    @param {1} clk: 1-bit input for clock signal
*/


module CoreDatapath(
    input clk

    // TODO: add outputs for memory mapped peripherals    
);
    
    // Instruction Fetch Stage Wires

    wire [1:0]  pcSel;      // Selects the next value of the program counter
    wire        pcStall;    // Stalls the instruction fetch stage if needed
    wire [63:0] pc;         // Program Counter output
    wire [63:0] nextPc;     // Next value of the Program Counter
    wire [63:0] pc4;        // Value of Program Counter plus 4
    
    wire [31:0] imOut;      // Instruction memory output
    wire [31:0] inst;       // Instruction to send to decode stage
    wire [31:0] nop;        // NOP instruction
    wire        instNop;    // Forces sending NOP to decode stage if needed

    assign nop = 32'b10011;


    // Instruction Decode Stage Wires (Excluding Control Unit outputs)
    wire [31:0] dinst;      // Instruction in decode stage
    wire [63:0] dpc;        // Program Counter in decode stage
    wire        ifidStall;  // Stalls the instruction decode stage if needed 
    wire [4:0]  rs1;        // Register Select 1
    wire [4:0]  rs2;        // Register Select 2
    wire [4:0]  rd;         // Destination Register
    wire [2:0]  funct3;     // 3-bit function code
    wire [6:0]  funct7;     // 7-bit function code
    wire [6:0]  opcode;     // Instruction opcode
    wire [63:0] rqa;        // Output of Regfile for Register A
    wire [63:0] rqb;        // Output of Regfile for Register B
    wire [63:0] qa;         // Output of forwarding mux for Register A
    wire [63:0] qb;         // Output of forwarding mux for Register B
    wire [63:0] imm64;      // 64-bit immediate value from immediate decoder
    wire [63:0] ctqa;       // Control Transfer qa, added to imm64 for jal and jalr
    wire [63:0] ctpc;       // Control Transfer Program Counter, used for jal and jalr

    assign rs1    = dinst[19:15];
    assign rs2    = dinst[24:20];
    assign rd     = dinst[11:7];
    assign funct3 = dinst[14:12];
    assign funct7 = dinst[31:25];
    assign opcode = dinst[6:0];

    // Instruction Decode Stage Wires from Control Unit outputs
    wire [2:0]  immType;    // Type of immediate value based on instruction type
    wire [1:0]  qaSel;      // Fowarding select for Register A
    wire [1:0]  qbSel;      // Fowarding select for Register B
    wire        isJalr;     // Indicates if instruction is jalr or jal
    wire        signedComp; // Indicates if compare in EXE is signed or unsigned
    wire        aSel;       // Selector for EXE A input
    wire [1:0]  bSel;       // Selector for EXE B input
    wire [3:0]  aluc;       // ALU Control
    wire        rSel;       // Selector whether ALU or Comparitor result is used
    wire        wmem;       // Memory write enable
    wire        m2reg;      // Memory to register selector
    wire        wreg;       // Register write enable
    wire [2:0]  bType;      // Type of branch


    // Execution Stage Wires from ID/EXE Register outputs
    wire [4:0]  erd;        // Destination Register in execute stage
    wire [63:0] epc;        // Program Counter in execute stage
    wire [63:0] eqa;        // Output of forwarding mux for Register A in execute stage
    wire        esignedComp;// Indicates if compare is signed or unsigned
    wire [63:0] eqb;        // Output of forwarding mux for Register B in execute stage
    wire [63:0] eimm64;     // 64-bit immediate value in execute stage
    wire        eaSel;      // Selector for EXE A input in execute stage
    wire [1:0]  ebSel;      // Selector for EXE B input in execute stage
    wire [3:0]  ealuc;      // ALU Control in execute stage
    wire        erSel;      // Selector whether ALU or Comparitor result is used in execute stage
    wire        ewmem;      // Memory write enable in execute stage
    wire [2:0]  efunct3;    // 3-bit function code in execute stage
    wire        em2reg;     // Memory to register selector in execute stage
    wire        ewreg;      // Register write enable in execute stage
    wire [2:0]  ebType;     // Type of branch in execute stage

    // Execution Stage Wires (excluding ID/EXE Register outputs)
    wire [63:0] ea;         // EXE A input
    wire [63:0] eb;         // EXE B input
    wire [63:0] alur;       // ALU result output
    wire        lt;         // indicates eqa < eqb
    wire        eq;         // indicates eqa = eqb
    wire [63:0] er;         // execution stage result


    // Memory Stage Wires
    wire [4:0]  mrd;        // Destination Register in memory stage
    wire [63:0] mr;         // execution stage result in memory stage
    wire [63:0] mqb;        // Output of forwarding mux for Register B in memory stage
    wire        mwmem;      // Memory write enable in memory stage
    wire [2:0]  mfunct3;    // 3-bit function code in memory stage
    wire        mm2reg;     // Memory to register selector in memory stage
    wire        mwreg;      // Register write enable in memory stage
    wire [63:0] md;         // Data Memory output


    // Write Back Stage Wires
    wire [4:0]  wrd;        // Destination Register in write back stage
    wire [63:0] wr;         // execution stage result in write back stage
    wire [63:0] wd;         // Data Memory output in write back stage
    wire        wm2reg;     // Memory to register selector in write back stage
    wire        wwreg;      // Register write enable in write back stage
    wire [63:0] wbData;     // Data to be written back to the regfile

    // Control Unit
    ControlUnit controlUnit(
        funct7, rs2, rs1, funct3, opcode, eq, lt, erd, mrd, rd, ewreg, mwreg,
        em2reg, mm2reg, ebType,
        aSel, bSel, aluc, rSel, wmem, m2reg, wreg, immType, bType, isJalr,
        signedComp, qaSel, qbSel, pcSel, pcStall, ifidStall, instNop
    );

    // Instruction Fetch Stage Modules
    ProgramCounter programCounter(nextPc, clk, pcStall, pc);
    HardInstructionMemory hardInstructionMemory(pc, imOut);
    Gp2to1Mux #(32) instMux (imOut, nop, instNop, inst);
    GpAdder #(64) pcAdder (64'h4, pc, pc4);
    Gp4to1Mux #(64) pcSelMux (pc4, ctpc, er, er, pcSel, nextPc);

    // Instruction Decode Stage Modules
    PipelineRegIFID pipelineRegIFID (pc, inst, clk, ifidStall, dpc, dinst);
    RegisterFile registerFile (rs1, rs2, wrd, wbData, wwreg, clk, rqa, rqb);
    ImmediateDecoder immediateDecoder (dinst[31:7], immType, imm64);
    Gp4to1Mux #(64) fwdaMux (rqa, er, mr, md, qaSel, qa);
    Gp4to1Mux #(64) fwdbMux (rqb, er, mr, md, qbSel, qb);
    Gp2to1Mux #(64) jalrMux (dpc, qa, isJalr, ctqa);
    GpAdder #(64) ctpcAdder (ctqa, imm64, ctpc);

    // Execution Stage Modules
    PipelineRegIDEXE pipelineRegIDEXE (
        rd, dpc, qa, qb, imm64, signedComp, funct3, aSel, bSel, aluc, rSel,
        wmem, m2reg, wreg, bType, clk,
        erd, epc, eqa, eqb, eimm64, esignedComp, efunct3, eaSel, ebSel, ealuc,
        erSel, ewmem, em2reg, ewreg, ebType
    );
    Gp2to1Mux #(64) exeAMux (eqa, epc, eaSel, ea);
    Gp4to1Mux #(64) exeBMux (eqb, eimm64, 64'h4, 64'h4, ebSel, eb);
    ALU alu (ea, eb, ealuc, alur);
    Comparator comparator (eqa, eqb, esignedComp, eq, lt);
    Gp2to1Mux #(64) exeRMux (alur, {63'h0, lt}, erSel, er);

    // Memory Stage Modules
    PipelineRegEXEMEM pipelineRegEXEMEM (
        erd, er, eqb, ewmem, efunct3, em2reg, ewreg, clk,
        mrd, mr, mqb, mwmem, mfunct3, mm2reg, mwreg
    );
    DataMemoryMapper dataMemoryMapper (mr, mqb, mwmem, mfunct3, clk, md);

    // Write Back Stage Modules
    PipelineRegMEMWB pipelineRegMEMWB (
        mrd, mr, md, mm2reg, mwreg, clk,
        wrd, wr, wd, wm2reg, wwreg
    );
    Gp2to1Mux #(64) wbMux (wr, wd, wm2reg, wbData);

endmodule
