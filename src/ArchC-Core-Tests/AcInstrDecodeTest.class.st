Class {
	#name : #AcInstrDecodeTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
AcInstrDecodeTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #arm }
AcInstrDecodeTest >> testArmB [
	| b |
	b := AcProcessorDescriptions armv5 decode: 16r0A03FC60.
	self assert: b name equals: 'b'
]

{ #category : #arm }
AcInstrDecodeTest >> testArmB_fromInstruction [
	| b decoded |
	b := AcProcessorDescriptions armv5 instructionAt: 'b'.
	decoded := b decode: (16r0A03FC60 toBitVector: 32).
	
	self assert: decoded name equals: 'b'
]

{ #category : #arm }
AcInstrDecodeTest >> testArmMov [
	| instr |
	instr := AcProcessorDescriptions armv5 decode: 16re3a03eff.   "mov r3, 0xff0"
	self assert: instr name equals: 'mov3'.
	self assert: (instr fieldValue: 'rotate') equals: 14.
	self assert: (instr fieldValue: 'imm8') equals: 255.

]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerAdd [
	| instr |
	instr := AcProcessorDescriptions powerpc decode: 16r62830001 .   "ori 3, 20, 0x1"
	self assert: instr name equals: 'ori'.
	self assert: (instr fieldValue: 'rs') equals: 20.
	self assert: (instr fieldValue: 'ra') equals: 3.
	self assert: (instr fieldValue: 'ui') equals: 1.
]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerAddi [
	| instr |
	instr := AcProcessorDescriptions powerpc decode: 16r38000000.   "addi r0, r0, 0, aka li r0, 0"
	self assert: instr name equals: 'addi'.
	self assert: (instr fieldValue: 'rt') equals: 0.
	self assert: (instr fieldValue: 'ra') equals: 0.
	self assert: (instr fieldValue: 'd') equals: 0.
	
]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerAddiSymbolic [
	| binary instr |
	binary := (16r3800 toBitVector: 16), ('x' toBitVector: 16).   "addi r0, r0, 0, aka li r0, 0"
	instr := AcProcessorDescriptions powerpc decode: binary.
	self assert: instr name equals: 'addi'.
	self assert: (instr fieldValue: 'rt') equals: 0.
	self assert: (instr fieldValue: 'ra') equals: 0.
	self assert: (instr fieldValue: 'd') equals: 'x'.
	
]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerLbz [
	"LBZ D-form (PPCArch, p.50):
	 lbz r2, 0x0001(r7).
	Test back and forth, i.e. assemble and then disassemble."

	| pdl lbz env grounded binary |
	pdl := AcProcessorDescriptions powerpc.
	lbz := pdl instructionAt: #lbz.
	env := Dictionary
		with: 'rt'-> 2
		with: 'ra'-> 7
		with: 'd' -> 1.
	grounded := lbz inEnvironment: env.
	binary := grounded emit32.
	binary := binary toBitVector: 32.
	self assert: grounded equals: (pdl decode: binary)
]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerOri [

	| pdl disassembledOri |
	pdl := AcProcessorDescriptions powerpc.
	disassembledOri := pdl decode: 16r60631234.
	self assert: disassembledOri format name equals: 'D4'.
	self assert: disassembledOri name equals: 'ori'.
]

{ #category : #powerpc }
AcInstrDecodeTest >> testPowerSc [
	| instr |
	instr := AcProcessorDescriptions powerpc decode: 16r44000002.   "sc"
	self assert: instr name equals: 'sc'.
	self assert: (instr fieldValue: 'lev') equals: 0.
]

{ #category : #powerpc }
AcInstrDecodeTest >> testSequence [ 
	| words instrs |
	words := #( 16r3c60ABCD 16r60631234 ).  "lis 3, ABCD; ori 3,3, 0x1234"
	instrs := AcProcessorDescriptions powerpc decode: words.
	self assert: instrs first name equals: 'addis'.
	self assert: instrs last  name equals: 'ori'.

]

{ #category : #sparc }
AcInstrDecodeTest >> testSparcAdd [
	| instr |
	instr := AcProcessorDescriptions sparcv8 decode: 16rA2002001. "%l1 := 1"
	self assert: instr name equals: 'add_imm'.
	self assert: (instr fieldValue: 'rs1') equals: 0.
	self assert: (instr fieldValue: 'rd')  equals: 17.
	self assert: (instr fieldValue: 'simm13') equals: 1.
]

{ #category : #sparc }
AcInstrDecodeTest >> testSparcNop [
	| instr |
	instr := AcProcessorDescriptions sparcv8 decode: 16r01000000.
	self assert: instr name equals: 'nop'.
]
