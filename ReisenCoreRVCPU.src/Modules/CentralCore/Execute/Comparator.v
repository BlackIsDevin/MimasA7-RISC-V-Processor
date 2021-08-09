/**
    This module implements a comparator for our pipelined RV64 CPU. It
        handles both signed and unsigned comparison operations, and outputs
        whether the first operand is less than or equal to the second operand.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} eqa: 64-bit input of first operand to be compared
    @param {64} eqb: 64-bit input of second operand to be compared
    @param {1} esignedComp: 1-bit input indicating whether the comparison is signed
        or unsigned

    @param {1} eq: 1-bit output indicating that the two operands are equal
    @param {1} lt: 1-bit output indicating that the first operand is less than
        the second operand
*/

module Comparator (
    input [63:0] eqa, eqb,
    input esignedComp,

    output reg eq, lt
);

    always @(*) begin
        // Equality comparison, sign-agnostic
        eq = (eqa == eqb);

        if (esignedComp == 1'b1)
            // Signed comparison
            lt = ($signed(eqa) < $signed(eqb));
        else
            // Unsigned comparison
            lt = (eqa < eqb);
    end
endmodule