"
Branch offset on ARM
"
Class {
	#name : #BIMM,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembling }
BIMM class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| encodedOffsets offset |
	encodedOffsets := anOperandInstantiation inEnvironment: e format: f.
	offset := encodedOffsets first signedValue * 4.
	"aWriteStream nextPutAll: '0x'; nextPutAll: (offset radix: 16)"
	aWriteStream nextPutAll: offset printString
]

{ #category : #API }
BIMM >> encodeInFields: fs accordingTo: format [
	self x isString ifTrue: [       
		fs isMultiField ifTrue: [ ^ self error ]. 
		^ Dictionary new
			at: fs operand put: '(', self x, ') >> 2';
			yourself 
	] ifFalse: [ 
		^ self encode: self x >> 2 inFields: fs accordingTo: format        
	].

]
