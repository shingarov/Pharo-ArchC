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

		aWriteStream nextPut: ${.
		"Original code was:

			aWriteStream nextPutAll: value astToString.
		"
		variables := value variableNames.
		variables size == 1 ifTrue: [ 
			"Simple function of one variable"
			aWriteStream nextPutAll: variables anyOne.
		] ifFalse: [ 
			"Function of multiple variables, print the whole AST"
			aWriteStream nextPutAll: value astToString.
		].
		aWriteStream nextPut: $} 
	] ifFalse: [
		value := value value.    
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

{ #category : #API }
PCREL >> encodeInFields: fs accordingTo: format [
	| width value |

	width := (fs widthAccordingTo: format).
	value := self x toBitVector: width.
	^ self encode: (value bitShiftRightArithmetic: 2) inFields: fs accordingTo: format
]
