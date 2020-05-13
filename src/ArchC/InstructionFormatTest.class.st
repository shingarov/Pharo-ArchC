Class {
	#name : #InstructionFormatTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'ArchC-Tests'
}

{ #category : #all }
InstructionFormatTest >> allFormatsAre32bits: aPDL [
	aPDL instructionFormats do: [ :f |
		"total instruction length adds up to 32"
		self assert: f binaryEncoding length equals: 32 ]
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
	self assert: (binary copyFrom: 31 to: 26) equals: ('opcd' asBitVector: 6).
	
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
