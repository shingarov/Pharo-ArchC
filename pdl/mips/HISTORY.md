## 2.4.0

* Revision numbers following the ArchC release
* Instructions with cycles annotations
* Two new .ac files to use with MPSoCBench (block and nonblock)
* mips_isa.cpp using the reserved work DATA_PORT to data request. See the [commit message](https://github.com/ArchC/mips/commit/fcf7eceb1e54de3037c3c9a0f785ab1606494c42).
* Interrupt handler support. It is inactive in standalone simulator.
* New PowerSC tables 

[Full changelog](https://github.com/ArchC/mips/compare/v2.3.0...v2.4.0)

## 2.3.0
* Revision numbers following the ArchC release
+ PowerSC support with power tables
* Memory instructions only use word size methods
+ Added id register for core identification

[Full changelog](https://github.com/ArchC/mips/compare/v1.0.2...v2.3.0)

## 1.0.2
* Bugfix in DEBUG mode

[Full changelog](https://github.com/ArchC/mips/compare/v1.0.1...v1.0.2)

## 1.0.1
* Updated syscall emulation library to setup multiprocessor stack
  (this version can be used with the updated compilers)

[Full changelog](https://github.com/ArchC/mips/compare/v1.0.0...v1.0.1)

## 1.0.0
* Changed name from mips1 to mips

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.8...v1.0.0)

## 0.7.8
+ Added binary utilities support files
* ArchC 2.0 compliant

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.7...v0.7.8)

## 0.7.7-archc2.0beta3
- Removed delayed assignements by creating the npc register
+ Created lo and hi registers and removed them from RB[32] and RB[33]

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.6...v0.7.7)

## 0.7.6-archc2.0beta3

+ Added license headers
* Changed the assembly information for 'break' instruction

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.5-1...v0.7.6)

## 0.7.5-archc2.0beta1

* Model compliant with ArchC 2.0beta1

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.5...v0.7.5-1)

## 0.7.5

+ Added 'bgtu' pseudo-insn
+ Added alternative assembly syntaxes to the lwl and lwr instructions
* Fixed the operand encoding of the nop 'instruction'

[Full changelog](https://github.com/ArchC/mips/compare/v0.7.4...v0.7.5)

## 0.7.4

+ Included assembly language syntax information

## 0.7.3

* Use ArchC support for debug messages: ac_debug_model.H
* Use operator[] syntax to read register banks, which is faster

## 0.7.2

+ Included optimization instruction methods for compiled simulation
* Separate nop instruction from sll to optimize simulation

## 0.7.1

+ Included file for GDB integration

## 0.7.0

* Model passed selected Mediabench and Mibench applications
