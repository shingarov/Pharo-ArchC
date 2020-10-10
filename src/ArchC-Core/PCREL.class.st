Class {
	#name : #PCREL,
	#superclass : #AsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembling }
PCREL class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| subfieldValues li |
	subfieldValues := anOperandInstantiation inEnvironment: e format: f.
	subfieldValues size = 1 ifFalse: [ self error ].
	li := subfieldValues first value. "BOGUS viz eg POWER 'b disp' is 2 bits off"
	aWriteStream nextPutAll:
		(li positive ifTrue: ['.+0x'] ifFalse: ['.-0x']).
	li abs printOn: aWriteStream base: 16 showRadix: false
]

{ #category : #API }
PCREL >> encodeInFields: fs accordingTo: format [
	fs isMultiField
		ifTrue: [ self error ]
		ifFalse: [ ^fs encodeSimpleValue: self x ]
]
