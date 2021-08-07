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

    // direct connections to the memory
    reg [63:0] bramDataIn;
    reg [63:0] bramDataOut;

    // 2 Kilobytes of on-chip memory
    reg [63:0] memory [0:255];

    // TODO: initialize memory with zeroes

    // this is awful lol
    always @(*) begin
        case (size)
            2'b00: begin // 8-bit operations
            case (address[2:0])
                3'b000: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[7:0]);
                    else
                        readData = $unsigned(bramDataOut[7:0]);
                    bramDataIn = {bramDataOut[63:8], writeData[7:0]};
                end
                3'b001: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[15:8]);
                    else
                        readData = $unsigned(bramDataOut[15:8]);
                    bramDataIn = {bramDataOut[63:16], writeData[15:8], bramDataOut[7:0]};
                end
                3'b010: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[23:16]);
                    else
                        readData = $unsigned(bramDataOut[23:16]);
                    bramDataIn = {bramDataOut[63:24], writeData[23:16], bramDataOut[15:0]};
                end
                3'b011: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[31:24]);
                    else
                        readData = $unsigned(bramDataOut[31:24]);
                    bramDataIn = {bramDataOut[63:32], writeData[31:24], bramDataOut[23:0]};
                end
                3'b100: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[39:32]);
                    else
                        readData = $unsigned(bramDataOut[39:32]);
                    bramDataIn = {bramDataOut[63:40], writeData[39:32], bramDataOut[31:0]};
                end
                3'b101: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[47:40]);
                    else
                        readData = $unsigned(bramDataOut[47:40]);
                    bramDataIn = {bramDataOut[63:48], writeData[47:40], bramDataOut[39:0]};
                end
                3'b110: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[55:48]);
                    else
                        readData = $unsigned(bramDataOut[55:48]);
                    bramDataIn = {bramDataOut[63:56], writeData[55:48], bramDataOut[47:0]};
                end
                3'b111: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[63:56]);
                    else
                        readData = $unsigned(bramDataOut[63:56]);
                    bramDataIn = {writeData[63:56], bramDataOut[55:0]};
                end
            endcase 
            end // end 8-bit operations
            2'b01: begin // 16-bit operations
            // in this case, if address[0] is not zero, misaligned access exception occurs
            // this exception currently doesn't occur, and will be implemented in the future
            case (address[2:1])
                2'b00: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[15:0]);
                    else
                        readData = $unsigned(bramDataOut[15:0]);
                    bramDataIn = {bramDataOut[63:16], writeData[15:0]};
                end
                2'b01: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[31:16]);
                    else
                        readData = $unsigned(bramDataOut[31:16]);
                    bramDataIn = {bramDataOut[63:32], writeData[31:16], bramDataOut[15:0]};
                end
                2'b10: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[47:32]);
                    else
                        readData = $unsigned(bramDataOut[47:32]);
                    bramDataIn = {bramDataOut[63:48], writeData[47:32], bramDataOut[31:0]};
                end
                2'b11: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[63:48]);
                    else
                        readData = $unsigned(bramDataOut[63:48]);
                    bramDataIn = {writeData[63:48], bramDataOut[47:0]};
                end
            endcase 
            end // end 16-bit operations
            2'b10: begin // 32-bit operations
            // in this case, if address[1:0] is not zero, misaligned access exception occurs
            // this exception currently doesn't occur, and will be implemented in the future
            case (address[2])
                1'b0: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[31:0]);
                    else
                        readData = $unsigned(bramDataOut[31:0]);
                    bramDataIn = {bramDataOut[63:32], writeData[31:0]};
                end
                1'b1: begin
                    if (signExtended)
                        readData = $signed(bramDataOut[63:32]);
                    else
                        readData = $unsigned(bramDataOut[63:32]);
                    bramDataIn = {writeData[63:32], bramDataOut[31:0]};
                end
            endcase 
            end // end 32-bit operations
            2'b11: begin // 64-bit operations
                readData = bramDataOut;
                bramDataIn = writeData;
            end // end 64-bit operations
        endcase
    end

    always @(negedge clk) begin
        if (writeEnable == 1'b1)
            memory[address[10:3]] = bramDataIn;
        bramDataOut = memory[address[10:3]];
    end

endmodule