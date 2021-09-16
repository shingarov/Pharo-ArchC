Class {
	#name : #InstructionFormatTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Core-Tests'
}

{ #category : #accessing }
InstructionFormatTest class >> resources [
	^ Array with: AcProcessorDescriptionsResource

]

{ #category : #all }
InstructionFormatTest >> allFormatsAre32bits: aPDL [
	aPDL instructionFormats do: [ :f |
		"total instruction length adds up to 32"
		self assert: f binaryEncoding length equals: 32 ]
]

{ #category : #'total widths' }
InstructionFormatTest >> maxOperandWidth: archSym [
	| instructions |
	instructions := (AcProcessorDescriptions perform: archSym)
			instructions values.
	^instructions inject: 0 into: [ :soFar :instr |
		| thisWidth |
		thisWidth := instr externalBindingBits.
		thisWidth > soFar
			ifTrue: [thisWidth]
			ifFalse: [soFar]].

]

{ #category : #all }
InstructionFormatTest >> testAllFormatsAre32bits [
	self allFormatsAre32bits: AcProcessorDescriptions powerpc.
	self allFormatsAre32bits: AcProcessorDescriptions mips.
	self allFormatsAre32bits: AcProcessorDescriptions armv5.
	self allFormatsAre32bits: AcProcessorDescriptions sparcv8.
]

{ #category : #powerpc }
InstructionFormatTest >> testFieldIsSigned [
	| d1 |
	d1 := AcProcessorDescriptions powerpc instructionFormats at: 'D1'.
	self assert: (d1 isSigned: 'd').
	self deny: (d1 isSigned: 'opcd').
]

{ #category : #powerpc }
InstructionFormatTest >> testFormatEmission [
	| x4 binary |
	x4 := AcProcessorDescriptions powerpc instructionFormats at: #X4.
	binary := x4 binaryEncoding.
	
	"total instruction length adds up to 32"
	self assert: binary length equals: 32.
	
	"the most-significant 6 bits are the opcd"
	self assert: (binary copyFrom: 31 to: 26) equals: ('opcd' toBitVector: 6).
	
	"the LSB is always 0"
	self assert: (binary copyFrom: 0 to: 0) equals: 0
]

{ #category : #powerpc }
InstructionFormatTest >> testFormatFieldPosition [
	| d1 |
	d1 := AcProcessorDescriptions powerpc instructionFormats at: 'D1'.
	self assert: (d1 positionOf: 'opcd') equals: 31.
	self assert: (d1 positionOf: 'd')    equals: 15
]

{ #category : #powerpc }
InstructionFormatTest >> testFormatFieldWidth [
	| d1 |
	d1 := AcProcessorDescriptions powerpc instructionFormats at: 'D1'.
	self assert: (d1 widthOf: 'opcd') equals: 6.
	self assert: (d1 widthOf: 'd')    equals: 16. "not -16!"
]

{ #category : #powerpc }
InstructionFormatTest >> testFormatOfInstruction [
	| pdl |
	pdl := AcProcessorDescriptions powerpc.
	self assert: (pdl instructionAt: #mcrf) format name   equals: 'XL3'.
	self assert: (pdl instructionAt: #lwz) format name    equals: 'D1'.
	self assert: (pdl instructionAt: #rlwinm) format name equals: 'M2'.
	self assert: (pdl instructionAt: #cmpi) format name   equals: 'D5'.


]

{ #category : #'total widths' }
InstructionFormatTest >> testLwzWidth [
	| lwz |
	lwz := AcProcessorDescriptions powerpc instructionAt: #lwz.
	self assert: lwz externalBindingBits equals: 5+5+16
]

{ #category : #'total widths' }
InstructionFormatTest >> testMostVariedOperands [
	| maxPPC maxMIPS maxARM maxSPARC |
	maxPPC   := self maxOperandWidth: #powerpc.
	maxMIPS  := self maxOperandWidth: #mips.
	maxARM   := self maxOperandWidth: #armv5.
	maxSPARC := self maxOperandWidth: #sparcv8.
	
]

{ #category : #'total widths' }
InstructionFormatTest >> testMostVariedOperandsARM [
	| instructions max fatInstructions fatInstructionNames |
	instructions := AcProcessorDescriptions armv5 instructions values.
	max := instructions inject: 0 into: [ :soFar :instr |
		| thisWidth |
		thisWidth := instr externalBindingBits.
		thisWidth > soFar
			ifTrue: [thisWidth]
			ifFalse: [soFar]].
	fatInstructions := instructions select: [ :inst | inst externalBindingBits = max ].
	fatInstructionNames := fatInstructions collect: #name.
	self assert: fatInstructionNames equals: #(b)
]

{ #category : #'total widths' }
InstructionFormatTest >> testMostVariedOperandsPPC [
	| instructions max fatInstructions fatInstructionNames |
	instructions := AcProcessorDescriptions powerpc instructions values.
	max := instructions inject: 0 into: [ :soFar :instr |
		| thisWidth |
		thisWidth := instr externalBindingBits.
		thisWidth > soFar
			ifTrue: [thisWidth]
			ifFalse: [soFar]].
	self assert: max equals: 5+5+16.
	fatInstructions := instructions select: [ :inst | inst externalBindingBits = max ].
	fatInstructionNames := fatInstructions collect: #name.
	self assert: (fatInstructionNames includes: #lwz).
	self assert: (fatInstructionNames includes: #stw).
]

{ #category : #'total widths' }
InstructionFormatTest >> testMostVariedOperandsSPARC [
	| instructions max fatInstructions fatInstructionNames |
	instructions := AcProcessorDescriptions sparcv8 instructions values.
	max := instructions inject: 0 into: [ :soFar :instr |
		| thisWidth |
		thisWidth := instr externalBindingBits.
		thisWidth > soFar
			ifTrue: [thisWidth]
			ifFalse: [soFar]].
	self assert: max equals: 30.
	fatInstructions := instructions select: [ :inst | inst externalBindingBits = max ].
	fatInstructionNames := fatInstructions collect: #name.
	"CALL is the only one that can jump anywhere in the 32-bit space"
	self assert: fatInstructionNames equals: #(call)
]

{ #category : #powerpc }
InstructionFormatTest >> testPpcBLA [
	| pdl bla instance |
	pdl := AcProcessorDescriptions powerpc.
	bla := pdl instructionAt: #bla.
	instance := bla inEnvironment: (Dictionary newFromAssociations: {'li'->0}).
	self assert: instance binaryEncoding value equals: 2r01001000000000000000000000000011   "16r48000003"
]
