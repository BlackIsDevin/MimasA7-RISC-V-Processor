/**
    This module implements the immediate decoder for our RISC-V core. The
        immediate type to decode is determined by the control unit and passed
        into this module.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param {25} dinstTop: input top 25 bits of dinst (bits 31 through 7)
    @param {3} immType: input from control unit that determines the immediate
        type
*/
module ImmediateDecoder (
    input [31:7] dinstTop,
    input [2:0] immType,

    output [63:0] imm64
);

    reg [30:0] decodedImmediate;

    // force top 33 bits to always be top bit of instruction, should simplify
    // synthesis model a bit and reduce unnecessary LUT usage maybe?
    assign imm64 = {{33{dinstTop[31]}}, decodedImmediate};

    always @(*) begin
        case (immType)
            3'b000: // I-type instructions
                decodedImmediate = {
                    {20{dinstTop[31]}},
                    dinstTop[30:20]
                };
            3'b001: // S-type instructions
                decodedImmediate = {
                    {20{dinstTop[31]}},
                    dinstTop[30:25],
                    dinstTop[11:7]
                };
            3'b010: // B-type instructions
                decodedImmediate = {
                    {19{dinstTop[31]}},
                    dinstTop[7],
                    dinstTop[30:25],
                    dinstTop[11:8],
                    1'b0
                };
            3'b011: // U-type instructions
                decodedImmediate = {
                    dinstTop[30:20],
                    dinstTop[19:12],
                    12'b0
                };
            3'b100: // J-type instructions
                decodedImmediate = {
                    {11{dinstTop[31]}},
                    dinstTop[19:12],
                    dinstTop[20],
                    dinstTop[30:21],
                    1'b0
                };
            default: // all other instructions in which immediates aren't used
                decodedImmediate = 31'hx;
        endcase
    end

endmodule