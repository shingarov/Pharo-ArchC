Class {
	#name : #ProcessorInstructionTest,
	#superclass : #TestCase,
	#instVars : [
		'powerpc'
	],
	#category : #'ArchC-Tests'
}

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
	| ori concrete |
	ori := AcProcessorDescriptions powerpc instructionAt: 'ori'.
	concrete := ori decode: 16r60830001. "ori 3,20,0x1"
	self deny: concrete binaryEncoding isSymbolic.
	self assert: ori binaryEncoding isSymbolic. "check that #decode: did not destroy the original"
	self assert: concrete name equals: 'ori'.
	self assert: concrete binaryEncoding value equals: 16r60830001
]

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testDecodePartial [
	| ori  partialBinary concrete |
	ori := AcProcessorDescriptions powerpc instructionAt: 'ori'.
	partialBinary := (16r6083 asBitVector: 16), (IntSymbol sym: 'UnsignedImmediate' length: 16). "ori 3,4,UnsignedImmediate"
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
	[ ori decode: 0 ] "inconsistent with ori"
		on: Unsat do: [ ^self ].
	self assert: false.
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

{ #category : #'tests - decoding' }
ProcessorInstructionTest >> testLbz [
	"LBZ D-form (PPCArch, p.50):
	 lbz r2, 0x0001(r7) "

	| lbz decoded offset |
	lbz := AcProcessorDescriptions powerpc instructionAt: #lbz.
	decoded := lbz decode: 16r8847FFFF.
	offset := decoded fieldValue: 'd'.
	self assert: offset equals: -1
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
	| pdl cmp env binary rangeBF rangeRA |
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
	self assert: (binary subrange: rangeBF) isLeaf.
	self assert: (binary subrange: rangeBF) isSymbolic.
	
	rangeRA := cmp rangeOf: 'ra'.
	self assert: rangeRA first equals: 20.
	self assert: rangeRA last  equals: 16.
	self assert: (binary subrange: rangeRA) isLeaf.
	self deny: (binary subrange: rangeRA) isSymbolic.
	self assert: (binary subrange: rangeRA) equals: 27

]
