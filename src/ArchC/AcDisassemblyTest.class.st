Class {
	#name : #AcDisassemblyTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests'
}

{ #category : #powerpc }
AcDisassemblyTest >> testPowerAdd [
	| instr |
	instr := AcProcessorDescriptions powerpc disassemble: 16r62830001 .   "ori 3, 20, 0x1"
	self assert: instr name equals: 'ori'.
	self assert: (instr fieldValue: 'rs') equals: 20.
	self assert: (instr fieldValue: 'ra') equals: 3.
	self assert: (instr fieldValue: 'ui') equals: 1.
]

{ #category : #powerpc }
AcDisassemblyTest >> testPowerAddi [
	| instr |
	instr := AcProcessorDescriptions powerpc disassemble: 16r38000000.   "addi r0, r0, 0, aka li r0, 0"
	self assert: instr name equals: 'addi'.
	self assert: (instr fieldValue: 'rt') equals: 0.
	self assert: (instr fieldValue: 'ra') equals: 0.
	self assert: (instr fieldValue: 'd') equals: 0.
	
]

{ #category : #powerpc }
AcDisassemblyTest >> testPowerLbz [
	"LBZ D-form (PPCArch, p.50):
	 lbz r2, 0x0001(r7).
	Test back and forth, i.e. assemble and then disassemble."

	| pdl lbz env grounded binary |
	pdl := AcProcessorDescriptions powerpc.
	lbz := pdl instructionAt: #lbz.
	env := Dictionary new
		at: #rt put: 2;
		at: #ra put: 7;
		at: #d put: 1;
		yourself.
	grounded := lbz inEnvironment: env.
	binary := grounded emit32.
	binary := binary asBitVector: 32.
	self assert: grounded equals: (pdl disassemble: binary)
]

{ #category : #powerpc }
AcDisassemblyTest >> testPowerOri [

	| pdl disassembledOri |
	pdl := AcProcessorDescriptions powerpc.
	disassembledOri := pdl disassemble: 16r60631234.
	self assert: disassembledOri format name equals: 'D4'.
	self assert: disassembledOri name equals: 'ori'.
]

{ #category : #'riscv-r32i' }
AcDisassemblyTest >> testR32iRadd [
	| instr |
	instr := AcProcessorDescriptions riscv disassemble: 16r00000893. "addi r17 <- 0"
	self assert: instr name equals: 'ADDI'.
	self assert: (instr fieldValue: 'rs1') equals: 0.
	self assert: (instr fieldValue: 'rd')  equals: 17.
	self assert: (instr fieldValue: 'op') equals: 19.
]

{ #category : #powerpc }
AcDisassemblyTest >> testSequence [ 
	| words instrs |
	words := #( 16r3c60ABCD 16r60631234 ).  "lis 3, ABCD; ori 3,3, 0x1234"
	instrs := AcProcessorDescriptions powerpc disassemble: words.
	self assert: instrs first name equals: 'addis'.
	self assert: instrs last  name equals: 'ori'.

]

{ #category : #sparc }
AcDisassemblyTest >> testSparcAdd [
	| instr |
	instr := AcProcessorDescriptions sparcv8 disassemble: 16rA2002001. "%l1 := 1"
	self assert: instr name equals: 'add_imm'.
	self assert: (instr fieldValue: 'rs1') equals: 0.
	self assert: (instr fieldValue: 'rd')  equals: 17.
	self assert: (instr fieldValue: 'simm13') equals: 1.
]

{ #category : #sparc }
AcDisassemblyTest >> testSparcNop [
	| instr |
	instr := AcProcessorDescriptions sparcv8 disassemble: 16r01000000.
	self assert: instr name equals: 'nop'.
]
