## 2.4.0

* Revision numbers following the ArchC release
* Instructions with cycles annotations
* Two new .ac files to use with MPSoCBench (block and nonblock)
* arm_isa.cpp using the reserved work DATA_PORT to data request. See the [commit message](https://github.com/ArchC/arm/commit/2eb30a551d11636adaede7db86167b43269d56e8).
* Interrupt handler support. It is inactive in standalone simulator. 

[Full changelog](https://github.com/ArchC/arm/compare/v2.3.0...v2.4.0)

## 2.3.0
* Revision numbers following the ArchC release
+ Added id register for core identification
* Special case in LSM/STM was handled. Now, it's possible use Rn in Rlist, e.g., 'push {sp, ...}'
* Fixed the number of register in 16

[Full changelog](https://github.com/ArchC/arm/compare/v1.0.1...v2.3.0)

## 1.0.1
* Bugfix in BX, RSC and SBC instructions

[Full changelog](https://github.com/ArchC/arm/compare/v1.0.0...v1.0.1)

## 1.0.0
* ArchC 2.2 compliant

[Full changelog](https://github.com/ArchC/arm/compare/v0.7.0...v1.0.0)

## 0.7.0

* Model passed selected Mediabench and Mibench applications
* ArchC 2.1 compliant
* Support for automatic generation of binary tools
* Support for dynamic linker and loader when reading ELF files
* Support for GDB
* Support for compiled simulator and interpreted simulator
