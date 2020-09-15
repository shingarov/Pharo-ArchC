Class {
	#name : #PCRELLDR,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
}

{ #category : #'as yet unclassified' }
PCRELLDR class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| uAndImm u imm12 |
	anOperandInstantiation operands = #('u' 'imm12') asOrderedCollection
		ifFalse: [self error: 'Modifier "exp(pcrelldr)" can only be used with u+imm12'].
	uAndImm := anOperandInstantiation inEnvironment: e format: f.
	u := uAndImm first value.
	imm12 := uAndImm second value.
	u = 0 ifTrue: [ aWriteStream nextPut: $- ]. "0 -> PC-imm12, 1 -> PC+imm12"
	imm12 printOn: aWriteStream  base: 10
]
