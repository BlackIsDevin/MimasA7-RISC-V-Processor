/**
    This module acts as a testbench for our datapath.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)
*/

module DatapathTestbench ();

    reg clk;

    CoreDatapath coreDatapath(clk);

    initial clk = 0;
    always #5 clk = ~clk;

endmodule  