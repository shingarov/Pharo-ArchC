Class {
	#name : #TextDisassemblyTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests'
}

{ #category : #tests }
TextDisassemblyTest >> testPowerAdd [
	| instr text |
	instr := AcProcessorDescriptions powerpc disassemble: 16r62830001 .
	text := instr disassemble.
	self assert: text equals: 'ori 3, 20, 0x1'.

]

{ #category : #tests }
TextDisassemblyTest >> testRiscvJAL [
	| instr text |
	instr := AcProcessorDescriptions riscv disassemble: 16r68a2476f .   "JAL x14, 2*0x12345"
	text := instr disassemble.
	self assert: text equals: 'JAL $sp, 0x12345'.
	
	"There is actually a problem with the ArchC model of RISC-V,
	so this test is in fact WRONG:
	as jumps can never be to an odd address,
	the immediate here is [20:1].
	So in RISC-V assembler, the jump target is notated 0x2468A, not 0x12345."
	self flag: #BOGUS

]
