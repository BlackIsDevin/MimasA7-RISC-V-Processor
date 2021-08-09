/**
    This module acts as a hard-coded instruction memory module. This will
        be used for storing all code for the time being, and later will be
        repurposed as a hard-coded BIOS-like ROM for loading code from an SD
        card into RAM. This might also be potentially used for storing system
        call handlers or other potentially useful things.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param address input address for the instruction memory
    @param instruction output instruction from the instruction memory
*/

module HardInstructionMemory(
    input [63:0] address,

    output reg [31:0] instruction
);

    reg [31:0] hardMemory [0:256];

    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            hardMemory[i] = 32'b10011; // NOP instructions

        // TODO program will go here

    end
    
    always @(*) begin
        if (|address[63:10] == 0)
            instruction = hardMemory[address[9:2]];
        else
            instruction = 32'b10011;
    end

endmodule
