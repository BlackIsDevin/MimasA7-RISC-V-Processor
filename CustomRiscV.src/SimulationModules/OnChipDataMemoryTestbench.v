/**
    This module is used to test the functionality of the OnChipDataMemory
    module.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)
*/

module OnChipDataMemoryTestbench ();
    reg [10:0] address;
    reg [63:0] writeData;
    reg signExtended;
    reg [1:0] writeSize;
    reg writeEnable;
    reg clk;

    wire [63:0] readData;

    OnChipDataMemory ocdm(address, writeData, signExtended, writeSize, writeEnable, clk, readData);

    initial begin
        address = 0;
        writeData = 64'h0;
        signExtended = 0;
        writeSize = 0;
        writeEnable = 0;
        clk = 0;
        #15
        address = 8;
        writeData = 64'hAAAABBBBAAAABBBB; // writes to mem
        writeSize = 2'b11;
        writeEnable = 1;
        #10
        writeEnable = 0;
        writeData = 64'hCCCC3333CCCC3333; // not written to mem
        #10
        writeEnable = 1;
        writeSize = 2'b01;
        writeData = 64'hDDDD4444DDDD4444; // only lower 16 bits written to mem
        #10
        writeEnable = 0;
        writeSize = 2'b11;
        writeData = 64'hEEEEE5555EEEEE5555; // not written to mem

    end

    // create clock signal
    always #5 clk = ~clk;

endmodule