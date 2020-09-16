Class {
	#name : #PCRELLDR,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Parsing'
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

{ #category : #API }
PCRELLDR >> encodeInFields: fs "OperandInstantiation" accordingTo: format [
	x isString
		ifTrue: [ 	self shouldBeImplemented "symbolic value, see similar implementation in AIMM" ]
		ifFalse: [ ^Dictionary new
			at: 'imm12' put: (x abs);
			at: 'u' put: (x negative ifTrue: [0] ifFalse: [1]);
			yourself ]
]
