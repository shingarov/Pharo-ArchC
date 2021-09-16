Class {
	#name : #ProcessorInstructionTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
ProcessorInstructionTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #'tests - binary width' }
ProcessorInstructionTest >> allInstructionsAre32bits: aPDL [
	aPDL instructions do: [ :instr |
		"total instruction length adds up to 32"
		self assert: instr binaryEncoding length equals: 32 ]
]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testAddiFigure2 [
	| instruction operands grounded |
	instruction := AcProcessorDescriptions powerpc instructionAt: #addi.
	operands := Dictionary new
		at: 'd' put: 1;
		at: 'rt' put: 3;
		at: 'ra' put: 3;
		yourself.
	grounded := instruction inEnvironment: operands.
	self assert: grounded binaryEncoding equals: 16r38630001
]

{ #category : #'tests - binary width' }
ProcessorInstructionTest >> testAllInstructionsAre32bits [
	self allInstructionsAre32bits: AcProcessorDescriptions powerpc.
	self allInstructionsAre32bits: AcProcessorDescriptions mips.
	self allInstructionsAre32bits: AcProcessorDescriptions armv5.
	self allInstructionsAre32bits: AcProcessorDescriptions sparcv8.
]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testCmpPartial [
	"Compare X-form (PPCArch, p.99):
	 cmp 1,r27,r0 "
	| pdl cmp env grounded bf ra |
	pdl := AcProcessorDescriptions powerpc.
	cmp := pdl instructionAt: #cmp.
	env := Dictionary new
		at: #l  put: 0; "Even L=0 always, the PDL leaves it variable in set_decoder"
		at: #ra put: 27;
		at: #rb put: 0;
		yourself.
	"bf is still unknown!"
	grounded := cmp inEnvironment: env.
	bf := grounded field: 'bf'.
	self assert: bf sym equals: 'bf'.
	ra := grounded field: 'ra'.
	self assert: ra value equals: 27.

]

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testDecodeInt [
	| ori ground |
	ori := AcProcessorDescriptions powerpc instructionAt: 'ori'.
	ground := ori decode: (16r60830001 toBitVector: 32). "ori 3,20,0x1"
	self deny: ground binaryEncoding isSymbolic.
	self assert: ori binaryEncoding isSymbolic. "check that #decode: did not destroy the original"
	self assert: ground name equals: 'ori'.
	self assert: ground binaryEncoding value equals: 16r60830001
]

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testDecodePartial [
	| ori  partialBinary concrete |
	ori := AcProcessorDescriptions powerpc instructionAt: 'ori'.
	partialBinary := (16r6083 toBitVector: 16), ('UnsignedImmediate' toBitVector: 16). "ori 3,4,UnsignedImmediate"
	concrete := ori decode: partialBinary.
	self assert: (concrete fieldValue: 'opcd') equals: 24.
	self assert: (concrete field: 'ra') length equals: 5.
	self assert: (concrete field: 'ra') value equals: 3.
	self assert: (concrete fieldValue: 'rs') equals: 4.
	
]

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testDecodeUnsat [
	| ori |
	ori := AcProcessorDescriptions powerpc instructionAt: 'ori'.
	self assert: (ori decode: 0) isNil "inconsistent with ori"

]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testFullyUngrounded [
	| pdl cmp concreteCmp |
	pdl := AcProcessorDescriptions powerpc.
	cmp := pdl instructionAt: #cmp.
	self assert: cmp class equals: ProcessorInstructionDeclaration.
	concreteCmp := cmp inEnvironment: IdentityDictionary new.
	self assert: concreteCmp class equals: ProcessorInstruction.
]

{ #category : #'tests - mips' }
ProcessorInstructionTest >> testJrEncoding [
	" jr r3
	See MIPS Run, 1st Ed., p.217 et seq. "
	| mips jr grounded env |
	mips := AcProcessorDescriptions mips.
	jr := mips instructionAt: #jr.
	env := Dictionary new
		at: #rd put: 0;  " unused, must be 0 "
		at: #rt put: 0;  " unused, must be 0 "
		at: #shamt put: 0;  " unused, must be 0 "
		at: #rs put: 3;
		yourself.
	grounded := jr inEnvironment: env.
	self assert: grounded emit32 equals: 16r00600008
]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testLbzEncodingNegativeOffset [
	"LBZ D-form (PPCArch, p.50):
	 lbz r2, -1(r7) "

	| lbz env grounded |
	lbz := AcProcessorDescriptions powerpc instructionAt: #lbz.
	env := Dictionary new
		at: #rt put: 2;
		at: #ra put: 7;
		at: #d put: -1;
		yourself.
	grounded := lbz inEnvironment: env.
	self assert: grounded binaryEncoding equals: 16r8847FFFF
]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testMcrf [
	"Some instruction formats, e.g. XL3 on the PowerPC,
	 include constant bitfields.
	 MCRF (PPCArch, p.46) is an example of XL3-encoded instruction:
	 opcd:6 = 2r01011;
	 bf:3;
	 0:2;
	 bfa:3;
	 0:2;
	 0:5;
	 xog:10 = 0;
	 0:1.
	 Some of these constants can appear more than once at different widths --
	 see '0:2' and '0:1' here.
	 "
	| instruction operands grounded |
	instruction := AcProcessorDescriptions powerpc instructionAt: #mcrf.
	operands := Dictionary new
		at: 'bf' put: 1;
		at: 'bfa' put: 3;
		yourself.
	grounded := instruction inEnvironment: operands.
	self assert: grounded binaryEncoding equals: 2r01001100100011000000000000000000
]

{ #category : #'tests - riscv' }
ProcessorInstructionTest >> testRISCVadd [
"	| add operands grounded |
	add := AcProcessorDescriptions riscv instructionAt: #ADD.
	operands := Dictionary new
		at: 'rs1' put: 1;
		at: 'rs2' put: 2;
		at: 'rd'  put: 3;
		yourself.
	grounded := add inEnvironment: operands.
	self assert: grounded emit32 equals: 2r00000000001000001000000110110011
"
]

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testSTWNegativeOffset [
	| stw operands |
	stw := AcProcessorDescriptions powerpc instructionAt: #stw.
	operands := Dictionary new
		at: 'rs' put: 1;
		at: 'ra' put: 3;
		at: 'd' put: -1;
		yourself.
	self assert: (stw inEnvironment: operands) binaryEncoding equals: 2r10010000001000111111111111111111
]

{ #category : #'tests - mips' }
ProcessorInstructionTest >> testSllEncoding [
	" sll r1, r2, 2
	See MIPS Run, 1st Ed., p.217 et seq. "
	| mips sll env grounded |
	mips := AcProcessorDescriptions mips.
	sll := mips instructionAt: #sll.
	env := Dictionary new
		at: #rd put: 1;
		at: #rt put: 2;
		at: #shamt put: 2;
		at: #rs put: 0;  "Unused and must be set to 0"
		yourself.
	grounded := sll inEnvironment: env.
	self assert: grounded emit32 equals: 16r00020880
]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testSymbolicEncoding [
	"Compare X-form (PPCArch, p.99):
	 cmp 1,r27,r0 "
	| pdl cmp env binary rangeBF bfBits rangeRA raBits |
	pdl := AcProcessorDescriptions powerpc.
	cmp := pdl instructionAt: #cmp.
	env := Dictionary new
		at: #l  put: 0; "Even L=0 always, the PDL leaves it variable in set_decoder"
		at: #ra put: 27;
		at: #rb put: 0;
		yourself.
	"bf is still unknown!"
	binary := (cmp inEnvironment: env) binaryEncoding.
	
	rangeBF := cmp rangeOf: 'bf'.
	self assert: rangeBF first equals: 25.
	self assert: rangeBF last  equals: 23.
	bfBits := binary subrange: rangeBF.
	self assert: bfBits isLeaf.
	self assert: bfBits isSymbolic.
	
	rangeRA := cmp rangeOf: 'ra'.
	self assert: rangeRA first equals: 20.
	self assert: rangeRA last  equals: 16.
	raBits := binary subrange: rangeRA.
	self assert: raBits isLeaf.
	self deny: raBits isSymbolic.
	self assert: raBits equals: 27

]

{ #category : #'tests - powerpc' }
ProcessorInstructionTest >> testTrapiSubstitution [
	| instr groundedInstr encoding constituents |
	instr := AcProcessorDescriptions powerpc instructionAt: 'twi'.
	groundedInstr := instr inEnvironment: (Dictionary new
		at: 'ra' put: 12;
		at: 'si' put: 12345;
		yourself).
	encoding := groundedInstr binaryEncoding .
	self assert: encoding functorName  equals: 'concat'.
	constituents := encoding args.
	self assert: constituents size equals: 3.
	self assert: constituents first length equals: 6.
	self assert: constituents first value equals: 3.
	self assert: constituents second sym equals: 'to'.
	self assert: constituents third value == 16rC3039.

]
