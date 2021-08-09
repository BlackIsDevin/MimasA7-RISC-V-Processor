# ReisenCore RISC-V Processor for Mimas A7

This repo contains ReisenCore, the beginnings of a processor implementation of
the RISC-V RV64I ISA specification. This processor and supporting components are
designed to run on the Mimas A7 Revision 3 Development Board, although I am
considering porting this to run on the more popular Arty A7 Development Board
once I can get my hands on one.

## Why the name?

¯\\\_(ツ)\_/¯

## Future Goals

Currently my goal is to make a processor that implements all of the instructions
in the RISC-V RV64I ISA specification, with the exception of the ECALL and
EBREAK instructions. I also plan on optimizing my processor so that when
implemented, it can run at a clock rate of 100MHz or faster.

After this, My plan is to implement the rest of the RV64I base ISA, as well as
the following extension ISAs, listed in order of priority:

- Zicsr (Control and Status Register (CSR))
- Zmmul (Integer Multiplication, no Division)
- C (Compressed Instructions)
- F (Single-Precision Floating-Point)
- D (Double-Precision Floating-Point)
- A (Atomic Instructions)
- Q (Quad-Precision Floating-Point)

Somewhere during this timeline, I'd also like to implement a privledged mode,
specifically user-mode. I do not plan on adding a supervisor mode, as my focus
for this processor is more on embedded systems rather than linux-capable
systems.
