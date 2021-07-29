/**
    This module acts as an on-chip data memory module. Currently, it
    is the only non-peripheral memory supported by the processor. However, future
    iterations of the processor will support more memory types, including external
    DDR3 SDRAM memory and I/O memory.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} address: 64-bit input address for the memory read/write
    @param {64} writeData: 64-bit input data to write to memory
    @param {1} signExtended: 1-bit input for indicating whether to sign-extend
        or zero-extend the read data to 64-bits
    @param {2} size: 2-bit data read/write size indicated by instruction
    @param {1} writeEnable: 1-bit input write-enable flag
    @param {1} clk: 1-bit input clock signal

    @param {64} readData: 64-bit output data from memory
*/

module OnChipDataMemory (
    input [10:0] address,
    input [63:0] writeData,
    input signExtended,
    input [1:0] size,
    input writeEnable,
    input clk,

    output reg [63:0] readData
);

    // 2 Kilobytes of on-chip memory
    reg [7:0] memory [0:2047];

    always @(negedge clk) begin
        if (writeEnable == 1) begin
            case(size)
            2'h0: begin
                memory[address + 0] <= writeData[7:0]; 
            end
            2'h1: begin
                memory[address + 0] <= writeData[7:0];
                memory[address + 1] <= writeData[15:8];
            end
            2'h2: begin
                memory[address + 0] <= writeData[7:0];
                memory[address + 1] <= writeData[15:8];
                memory[address + 2] <= writeData[23:16];
                memory[address + 3] <= writeData[31:24];
            end
            2'h3: begin
                memory[address + 0] <= writeData[7:0];
                memory[address + 1] <= writeData[15:8];
                memory[address + 2] <= writeData[23:16];
                memory[address + 3] <= writeData[31:24];
                memory[address + 4] <= writeData[39:32];
                memory[address + 5] <= writeData[47:40];
                memory[address + 6] <= writeData[55:48];
                memory[address + 7] <= writeData[63:56];
            end
            endcase
        end
    end

    always @(*) begin
        case({~signExtended, size})
        2'h0: begin
            readData = $signed(memory[address]);
        end
        2'h1: begin
            readData[7:0] = memory[address + 0];
            readData[63:8] = $signed(memory[address + 1]);
        end
        2'h2: begin
            readData[7:0] = memory[address + 0];
            readData[15:8] = memory[address + 1];
            readData[23:16] = memory[address + 2];
            readData[63:24] = $signed(memory[address + 3]);
        end
        2'h3: begin
            readData[7:0] = memory[address + 0];
            readData[15:8] = memory[address + 1];
            readData[23:16] = memory[address + 2];
            readData[31:24] = memory[address + 3];
            readData[39:32] = memory[address + 4];
            readData[47:40] = memory[address + 5];
            readData[55:48] = memory[address + 6];
            readData[63:56] = memory[address + 7];
        end
        2'h4: begin
            readData[7:0] = memory[address];
            readData[63:8] = 56'h0;
        end
        2'h5: begin
            readData[7:0] = memory[address + 0];
            readData[15:8] = memory[address + 1];
            readData[63:16] = 48'h0;
        end
        2'h6: begin
            readData[7:0] = memory[address + 0];
            readData[15:8] = memory[address + 1];
            readData[23:16] = memory[address + 2];
            readData[31:24] = memory[address + 3];
            readData[63:32] = 32'h0;
        end
        2'h7: begin // not a valid function code
            readData = 64'hx;
        end
        endcase
    end

endmodule