/**
    This module holds all the data memory related hardware and maps the appropiate
        adresses to the data memory hardware. This module could benefit from the
        addition of bus interface hardware. Instruction Memory is not mappped here.
    
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} mr: 64-bit input memory address
    @param {64} mqb: 64-bit input data to be written to memory
    @param {1} mwmem: 1-bit input to indicate if data should be written to memory
    @param {3} mfunc3: 3-bit input indicating signedness and size of data to be 
        written or read
    @param {1} clk: 1-bit input for clock signal
    
    @param {64} md: 64-bit output data read from memory 
*/

module DataMemoryMapper (
    input [63:0] mr,
    input [63:0] mqb,
    input mwmem,
    input [2:0] mfunc3,
    input clk,

    output reg [63:0] md
);

    // TODO: initialize peripherals

    // initializing on-chip memory
    wire [63:0] onChipDataMemoryOut;
    wire onChipDataMemoryEnable = (~|mr[63:12]) & mr[11];
    wire onChipDataMemoryWriteEnable = onChipDataMemoryEnable & mwmem;
    OnChipDataMemory onChipDataMemory(
        mr[10:0],
        mqb,
        mfunc3[2],
        mfunc3[1:0],
        onChipDataMemoryWriteEnable,
        clk,
        onChipDataMemoryOut
    );

    // TODO: add peripherals

    always @(*) begin
        if (onChipDataMemoryEnable) begin
            md = onChipDataMemoryOut;
        end else begin
            md = 64'hx;
        end
    end

endmodule

/* mapping reference
    0x0000_0000_0000_0000 - 0x0000_0000_0000_03FF : hard instruction memory, read only
    0x0000_0000_0000_0400 - 0x0000_0000_0000_07FF : various peripherals
    0x0000_0000_0000_0800 - 0x0000_0000_0000_0FFF : on-chip data memory
    0x0000_0000_0000_1000 - 0xFFFF_FFFF_FFFF_FFFF : unconnected

    instruction memory cannot be accessed here, this will be changed in 
        future versions
*/
