Class {
	#name : #PCRELLDR,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembly }
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

{ #category : #encoding }
PCRELLDR class >> imm12Of: x [
	"ARM u+imm12 encoding"
	^x abs
]

{ #category : #encoding }
PCRELLDR class >> uOf: x [
	"ARM u+imm12 encoding"
	^x negative ifTrue: [0] ifFalse: [1]
]

{ #category : #API }
PCRELLDR >> encodeInFields: fs "OperandInstantiation" accordingTo: format [
	x isString
		ifTrue: [ 	^Dictionary new
			at: 'u' put: 'PCRELLDR uOf: (', x, ')';
			at: 'imm12' put: 'PCRELLDR imm12Of: (', x, ')';
			yourself ]
		ifFalse: [ ^Dictionary new
			at: 'imm12' put: (PCRELLDR imm12Of: x);
			at: 'u' put: (PCRELLDR uOf: x);
			yourself ]
]
