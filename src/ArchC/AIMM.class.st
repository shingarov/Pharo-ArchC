Class {
	#name : #AIMM,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
}

{ #category : #disassembling }
AIMM class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| rotAndImm rot imm |
	anOperandInstantiation operands = #('rotate' 'imm8') asOrderedCollection
		ifFalse: [self error: 'Right now, aimm modifier can only be used with rotate+imm8'].
	rotAndImm := anOperandInstantiation inEnvironment: e format: f.
	rot := rotAndImm first value.
	imm := 24 zeros, (rotAndImm second asBitVector: 8).
	imm := (imm rotateRight: rot*2) simplify.
	"to my (bgs) taste, a rather non-orthogonal convention that aimm is always signed"
	aWriteStream nextPutAll: imm signedValue asString
]
