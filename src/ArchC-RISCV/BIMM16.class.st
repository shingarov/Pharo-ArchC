Class {
	#name : #BIMM16,
	#superclass : #AcAsmOperandModifier,
	#category : #'ArchC-RISCV-Parsing'
}

{ #category : #disassembling }
BIMM16 class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f [
	| offset |

	offset := anOperandInstantiation isMultiField 
				ifTrue: [ anOperandInstantiation decodeComplexValue: e accordingTo: f ]
				ifFalse:[ anOperandInstantiation decodeSimpleValue: e ].
	offset := offset << 1.
	"aWriteStream nextPutAll: '0x'; nextPutAll: (offset radix: 16)"

	offset isSymbolic ifTrue: [ 
		| names |

		names := offset variableNames.
		names size == 1 ifTrue: [ 
			aWriteStream nextPut: ${; nextPutAll: names anyOne; nextPut: $}.
			^ self.
		].
	].
	aWriteStream nextPutAll: offset simplify signedValue printString
]

{ #category : #API }
BIMM16 >> encodeInFields: fs accordingTo: format [
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 1) inFields: fs accordingTo: format
]
