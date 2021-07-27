/**
    This module acts as an on-chip data memory module. Currently, it
    is the only memory supported by the processor. However, future iterations
    of the processor will support more memory types, including external
    DDR3 SDRAM memory and I/O memory.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} mr: 64-bit input address for the memory read/write
    @param {64} mqb: 64-bit input data to write to memory
    @param {3} mfunc3: 3-bit data read/write type indicated by instruction
    @param {1} mwmem: 1-bit input write-enable flag
    @param {1} clk: 1-bit input clock signal

    @param {64} dmOut: 64-bit output data from memory
*/

module OnChipDataMemory (
    input [63:0] mr,
    input [63:0] mqb,
    input [2:0] mfunc3,
    input mwmem,
    input clk,

    output reg [63:0] dmOut
);

    // 2 Kilobytes of on-chip memory
    reg [7:0] memory [0:2047];

    always @(negedge clk) begin
        if (mwmem == 1) begin
            case(mfunc3[1:0])
            2'h0: begin
                memory[mr + 0] <= mqb[7:0]; 
            end
            2'h1: begin
                memory[mr + 0] <= mqb[7:0];
                memory[mr + 1] <= mqb[15:8];
            end
            2'h2: begin
                memory[mr + 0] <= mqb[7:0];
                memory[mr + 1] <= mqb[15:8];
                memory[mr + 2] <= mqb[23:16];
                memory[mr + 3] <= mqb[31:24];
            end
            2'h3: begin
                memory[mr + 0] <= mqb[7:0];
                memory[mr + 1] <= mqb[15:8];
                memory[mr + 2] <= mqb[23:16];
                memory[mr + 3] <= mqb[31:24];
                memory[mr + 4] <= mqb[39:32];
                memory[mr + 5] <= mqb[47:40];
                memory[mr + 6] <= mqb[55:48];
                memory[mr + 7] <= mqb[63:56];
            end
            endcase
        end
    end

    always @(*) begin
        case(mfunc3)
        2'h0: begin
            dmOut = $signed(memory[mr]);
        end
        2'h1: begin
            dmOut[7:0] = memory[mr + 0];
            dmOut[63:8] = $signed(memory[mr + 1]);
        end
        2'h2: begin
            dmOut[7:0] = memory[mr + 0];
            dmOut[15:8] = memory[mr + 1];
            dmOut[23:16] = memory[mr + 2];
            dmOut[63:24] = $signed(memory[mr + 3]);
        end
        2'h3: begin
            dmOut[7:0] = memory[mr + 0];
            dmOut[15:8] = memory[mr + 1];
            dmOut[23:16] = memory[mr + 2];
            dmOut[31:24] = memory[mr + 3];
            dmOut[39:32] = memory[mr + 4];
            dmOut[47:40] = memory[mr + 5];
            dmOut[55:48] = memory[mr + 6];
            dmOut[63:56] = memory[mr + 7];
        end
        2'h4: begin
            dmOut[7:0] = memory[mr];
            dmOut[63:8] = 56'h0;
        end
        2'h5: begin
            dmOut[7:0] = memory[mr + 0];
            dmOut[15:8] = memory[mr + 1];
            dmOut[63:16] = 48'h0;
        end
        2'h6: begin
            dmOut[7:0] = memory[mr + 0];
            dmOut[15:8] = memory[mr + 1];
            dmOut[23:16] = memory[mr + 2];
            dmOut[31:24] = memory[mr + 3];
            dmOut[63:32] = 32'h0;
        end
        2'h7: begin // not a valid function code
            dmOut = 64'hx;
        end
        endcase
    end

endmodule