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
	| value |

	value := (self decode: e fromFields: anOperandInstantiation accordingTo: f) simplify.

	value isSymbolic ifTrue: [
		| variables |

		variables := value variableNames.
		variables size == 1 ifTrue: [ 
			"If the variable name is valid (GNU) assembler label name,
			 output it without braces. See AcAsmFormatBuiltinChunk >> #assembler."
			| name |

			name := variables anyOne.
			((name allSatisfy:[:c | c isAlphaNumeric or:['_.$' includes:c]]) and: [ name first isDigit not ]) ifTrue: [ 
				"Valid (GNU) assembler label"
				aWriteStream nextPutAll: name.
			] ifFalse: [ 
				"Anything else"
				aWriteStream 
					nextPut: ${;
					nextPutAll: name;
					nextPut: $}.
			].
		] ifFalse: [ 
			"Function of multiple variables, print the whole AST"
			aWriteStream 
					nextPut: ${;
					nextPutAll: value astToString;
					nextPut: $}.
		].
	] ifFalse: [
		value := value signedValue.    
		value positive ifTrue: [ 
			aWriteStream nextPutAll: '.+0x'.
		] ifFalse: [ 
			aWriteStream nextPutAll: '.-0x'.
		].
		value abs
			printOn: aWriteStream
			base: 16
			showRadix: false
	].
]

{ #category : #queries }
PCREL class >> isPCREL [
	^ true
]

{ #category : #API }
PCREL >> encodeInFields: fs accordingTo: format [
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 2) inFields: fs accordingTo: format
]
