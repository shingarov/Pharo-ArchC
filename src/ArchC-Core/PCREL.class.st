Class {
	#name : #PCREL,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
PCREL class >> decode: bitfields fromFields: operandInstantiation accordingTo: format [
	^ (operandInstantiation decode: bitfields accordingTo: format) << 2
]

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
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 2) inFields: fs accordingTo: format
]
