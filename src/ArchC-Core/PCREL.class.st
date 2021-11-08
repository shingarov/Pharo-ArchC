Class {
	#name : #PCREL,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #disassembling }
PCREL class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f chunk: anObject [ 
	| subfieldValues  li |

	subfieldValues := anOperandInstantiation inEnvironment: e format: f.
	subfieldValues size = 1 ifFalse: [
		self error
	].
	li := subfieldValues first value.
	aWriteStream nextPutAll: (li positive ifTrue: [
				'.+0x'
			] ifFalse: [ '.-0x' ]).
	li abs 
		printOn: aWriteStream
		base: 16
		showRadix: false
]

{ #category : #API }
PCREL >> encodeInFields: fs accordingTo: format [
	^ self encode: self x inFields: fs accordingTo: format

]
