/**
    This module implements the control unit of our RISC-V core. It handles
        signal generation for execution of all instructions, as well as ALUC
        and forwarding signals.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param {7} funct7: input 7-bit function field from instruction
    @param {5} rs2: input 5-bit register 2 field from instruction
    @param {5} rs1: input 5-bit register 1 field from instruction
    @param {3} funct3: input 3-bit function field from instruction
    @param {7} opcode: input 7-bit opcode field from instruction
    @param {1} eq: input 1-bit equal flag from EXE stage, indicates eqa = eqb
    @param {1} lt: input 1-bit less-than flag from EXE stage, indicates eqa < eqb
    @param {5} erd: input 5-bit destination register from EXE stage
    @param {5} mrd: input 5-bit destination register from MEM stage
    @param {1} ewreg: input 1-bit write-back flag from EXE stage
    @param {1} mwreg: input 1-bit write-back flag from MEM stage
    @param {1} em2reg: input 1-bit WB Mux flag from EXE stage
    @param {1} mm2reg: input 1-bit WB Mux flag from MEM stage

    @param {1} aSel: output 1-bit EXE A Mux select flag, selects a input for ALU
    @param {1} bSel: output 1-bit EXE B Mux select flag, selects b input for ALU
    @param {4} aluc: output 4-bit ALU control field, selects ALU operation
    @param {1} rSel: output 1-bit EXE R Mux select flag, selects whether result for
        MEM & WB stages should use output from ALU or Comparator as a result value
    @param {1} wmem: output 1-bit MEM stage write flag, indicates whether MEM stage
        should write to memory
    @param {1} m2reg: output 1-bit WB Mux select flag, selects whether result from
        EXE or MEM stage should be written to register file
    @param {1} wreg: output 1-bit WB stage write flag, indicates whether WB stage
        should write to register file
    @param {3} immType: output 3-bit immediate type field, selects immediate type
    @param {3} bType: output 3-bit branch type field, selects branch type, MSB can
        be interpreted as an is-branch flag
    @param {1} isJalr: output 1-bit JALR flag, indicates whether instruction is JALR
    @param {1} signedComp: output 1-bit signed comparison flag, indicates whether
        comparison is signed or unsigned
    @param {2} qaSel: output 2-bit FWD A Mux select flag, selects a input for
        forwarding values from EXE or MEM stage to the ID stage if needed
    @param {2} qbSel: output 2-bit FWD B Mux select flag, selects b input for
        forwarding values from EXE or MEM stage to the ID stage if needed
    @param {2} pcSel: output 2-bit PCSel Mux select flag, selects the value
        for the next PC to be written to the PC register
    @param {1} pcStall: output 1-bit PC stall flag, indicates whether Program
        Counter should stall
    @param {1} ifidStall: output 1-bit IFID stall flag, indicates whether IFID
        Pipeline Register should stall
    @param {1} instNop: output 1-bit instruction Mux flag, selects whether instruction
        in IF stage should be executed or skipped
*/

module ControlUnit (
    input [6:0] funct7,
    input [4:0] rs2, rs1,
    input [2:0] funct3,
    input [6:0] opcode,
    input eq, lt,
    input [4:0] erd, mrd, rd,
    input ewreg, mwreg,
    input em2reg, mm2reg,
    input [2:0] ebType,

    output reg aSel,
    output reg [1:0] bSel,
    output reg [3:0] aluc,
    output reg rSel,
    output reg wmem, m2reg, wreg,
    output reg [2:0] immType,
    output [2:0] bType,
    output reg isJalr, signedComp,
    output reg [1:0] qaSel, qbSel,
    output reg [1:0] pcSel,
    output reg pcStall, ifidStall, instNop
);
    // assign for branch, this could be done in the always block but it's cleaner
    // to do it here
    reg isBranch;
    assign bType = {isBranch, funct3[2], funct3[0]};

    // register for handling regfile usage, used for deciding stalling
    reg rs1Usage, rs2Usage;

    // initial values for the control unit
    initial begin
        wmem = 0;
        wreg = 0;
        isBranch = 0;
        pcSel = 0;
        pcStall = 0;
        ifidStall = 0;
        instNop = 0;
    end

    always @(*) begin
        // handle main instruction execution
        case (opcode) 
            7'b0110011: begin // register arithmetic operations
                aSel = 1'b0;
                bSel = 2'h0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'hx;
                isBranch = 1'b0;
                isJalr = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b1;
                case (funct3)
                    3'b000: begin // ADD & SUB
                        aluc = funct7[5] ? 4'h1 : 4'h0;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b111: begin // AND
                        aluc = 4'h2;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b110: begin // OR
                        aluc = 4'h3;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b100: begin // XOR
                        aluc = 4'h4;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b001: begin // SLL
                        aluc = 4'h5;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b101: begin // SRL & SRA
                        aluc = funct7[5] ? 4'h7 : 4'h6;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b010: begin // SLT
                        aluc = 4'hx;
                        rSel = 1'b1;
                        signedComp = 1'b1;
                    end
                    3'b011: begin // SLTU
                        aluc = 4'hx;
                        rSel = 1'b1;
                        signedComp = 1'b0;
                    end
                endcase
            end
            7'b0111011: begin // 32-bit register arithmetic operations
                aSel = 1'b0;
                bSel = 2'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'hx;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b1;
                case (funct3)
                    3'b000: begin // ADDW & SUBW
                        aluc = funct7[5] ? 4'h9 : 4'h8;
                    end
                    3'b001: begin // SLLW
                        aluc = 4'hD;
                    end
                    3'b101: begin // SRLW & SRAW                    
                        aluc = funct7[5] ? 4'hF : 4'hE;
                    end
                endcase
            end
            7'b0010011: begin // immediate arithmetic operations
                aSel = 1'b0;
                bSel = 2'h1;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h0;
                isBranch = 1'b0;
                isJalr = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b0;
                case (funct3)
                    3'b000: begin // ADDI
                        aluc = 4'h0;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b111: begin // ANDI
                        aluc = 4'h2;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b110: begin // ORI
                        aluc = 4'h3;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b100: begin // XORI
                        aluc = 4'h4;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b001: begin // SLLI
                        aluc = 4'h5;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b101: begin // SRLI & SRAI
                        aluc = funct7[5] ? 4'h7 : 4'h6;
                        rSel = 1'b0;
                        signedComp = 1'bx;
                    end
                    3'b010: begin // SLTI
                        aluc = 4'hx;
                        rSel = 1'b1;
                        signedComp = 1'b1;
                    end
                    3'b011: begin // SLTIU
                        aluc = 4'hx;
                        rSel = 1'b1;
                        signedComp = 1'b0;
                    end
                endcase
            end
            7'b0011011: begin // 32-bit immediate arithmetic operations
                aSel = 1'b0;
                bSel = 2'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h1;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b0;
                case (funct3)
                    3'b000: begin // ADDIW
                        aluc = 4'h8;
                    end
                    3'b001: begin // SLLIW
                        aluc = 4'hD;
                    end
                    3'b101: begin // SRLIW & SRAWI
                        aluc = funct7[5] ? 4'hF : 4'hE;
                    end
                endcase
            end
            7'b1100011: begin // Branch operations
                aSel = 1'b1;
                bSel = 2'h1;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'bx;
                wreg = 1'b0;
                immType = 3'h2;
                isBranch = 1'b1;
                isJalr = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b1;
                case (funct3)
                    3'b000: begin // BEQ
                        signedComp = 1'bx;
                    end
                    3'b001: begin // BNE
                        signedComp = 1'bx;
                    end
                    3'b100: begin // BLT
                        signedComp = 1'b1;
                    end
                    3'b101: begin // BGE
                        signedComp = 1'b1;
                    end
                    3'b110: begin // BLTU
                        signedComp = 1'b0;
                    end
                    3'b111: begin // BGEU
                        signedComp = 1'b0;
                    end
                endcase
            end
            7'b0000011: begin // Loads
                aSel = 1'b0;
                bSel = 2'h1;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b1;
                wreg = 1'b1;
                immType = 3'h0;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b0;
            end
            7'b0100011: begin // Stores
                aSel = 1'b0;
                bSel = 2'h1;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b1;
                m2reg = 1'bx;
                wreg = 1'b0;
                immType = 3'h1;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b1;
                rs2Usage = 1'b1;
            end
            7'b0001111: begin // FENCE (no operation in our implementation)
                aSel = 1'bx;
                bSel = 2'hx;
                aluc = 4'hx;
                rSel = 1'bx;
                wmem = 1'b0;
                m2reg = 1'bx;
                wreg = 1'b0;
                immType = 3'hx;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
            7'b1110011: begin // ECALL & EBREAK (unimplemented/NOP in this version)
                aSel = 1'bx;
                bSel = 2'hx;
                aluc = 4'hx;
                rSel = 1'bx;
                wmem = 1'b0;
                m2reg = 1'bx;
                wreg = 1'b0;
                immType = 3'hx;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
            7'b0110111: begin // LUI
                aSel = 1'bx;
                bSel = 2'h1;
                aluc = 4'hB;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h3;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
            7'b0010111: begin // AUIPC
                aSel = 1'b1;
                bSel = 2'h1;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h3;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
            7'b1101111: begin // JAL
                aSel = 1'b1;
                bSel = 2'h2;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h4;
                isBranch = 1'b0;
                isJalr = 1'b0;
                signedComp = 1'bx;
                pcSel = 2'h1;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
            7'b1100111: begin // JALR
                aSel = 1'b1;
                bSel = 2'h2;
                aluc = 4'h0;
                rSel = 1'b0;
                wmem = 1'b0;
                m2reg = 1'b0;
                wreg = 1'b1;
                immType = 3'h0;
                isBranch = 1'b0;
                isJalr = 1'b1;
                signedComp = 1'bx;
                pcSel = 2'h1;
                rs1Usage = 1'b1;
                rs2Usage = 1'b0;
            end
            default: begin // handle invalid or unimplemented instructions
                // for now, the behavior of invalid or unimplemented instructions
                // is to interpret it as a NOP and just keep going, this will later
                // be changed to an exception once the hardware is more developed
                aSel = 1'bx;
                bSel = 2'hx;
                aluc = 4'hx;
                rSel = 1'bx;
                wmem = 1'b0;
                m2reg = 1'bx;
                wreg = 1'b0;
                immType = 3'hx;
                isBranch = 1'b0;
                isJalr = 1'bx;
                signedComp = 1'bx;
                pcSel = 2'h0;
                rs1Usage = 1'b0;
                rs2Usage = 1'b0;
            end
        endcase

        // handle forwarding
        if (ewreg && (erd != 5'h0) && (erd == rs1) && ~em2reg)
            qaSel = 2'h1;
        else if (mwreg & (mrd != 5'h0) & (mrd == rs1) & ~mm2reg)
            qaSel = 2'h2;
        else if (mwreg & (mrd != 5'h0) & (mrd == rs1) & mm2reg)
            qaSel = 2'h3;
        else
            qaSel = 2'h0;
    
        if (ewreg & (erd != 5'h0) & (erd == rs2) & ~em2reg)
            qbSel = 2'h1;
        else if (mwreg & (mrd != 5'h0) & (mrd == rs2) & ~mm2reg)
            qbSel = 2'h2;
        else if (mwreg & (mrd != 5'h0) & (mrd == rs2) & mm2reg)
            qbSel = 2'h3;
        else
            qbSel = 2'h0;
    
        // handle stalling for load words if needed
        if (ewreg & em2reg & (erd != 5'h0) & (rd != 5'h0) &
            ((rs1Usage & (rd == rs1)) | (rs2Usage & (rd == rs2))))
        begin
            wreg = 1'b0;
            wmem = 1'b0;
            pcStall = 1'b1;
            ifidStall = 1'b1;
        end else begin
            pcStall = 1'b0;
            ifidStall = 1'b0;
        end
        
        // handle forcing no-ops for branch instructions if needed
        if (
            (ebType == 3'h4 & eq == 1'b1) | // BEQ
            (ebType == 3'h5 & eq == 1'b0) | // BNE
            (ebType == 3'h6 & lt == 1'b1) | // BLT
            (ebType == 3'h7 & lt == 1'b0)   // BGE
        )
        begin
            wreg = 1'b0;
            wmem = 1'b0;
            pcSel = 2'h2;
            instNop = 1'b1;
        end else begin
            instNop = 1'b0;
        end
        
    end


endmodule