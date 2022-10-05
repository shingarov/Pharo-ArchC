Class {
	#name : #AcAsmOperandModifier,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
AcAsmOperandModifier class >> decode: bitfields fromFields: operandInstantiation accordingTo: format [
	self subclassResponsibility
]

{ #category : #disassembling }
AcAsmOperandModifier class >> disassemble: anOperandInstantiation to: aWriteStream inEnvironment: e format: f chunk: builtin [ 
	|  value |

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
			aWriteStream nextPutAll: value printString.
		].
		aWriteStream nextPut: $} 
	] ifFalse: [
		"
		Print %imm chunks as unsigned hex number
		and   %exp chunks as signed decimal number
		"
		builtin type = '%imm' ifTrue: [ 
			aWriteStream nextPutAll: '0x'.
			value value
				printOn: aWriteStream
				base: 16
				showRadix: false
		] ifFalse: [ 
			builtin type = '%exp' ifTrue: [ 
				value signedValue printOn: aWriteStream
			] ifFalse: [ 
				self error: 'Not (yet) supported builtin type: ', builtin type
			].
		].
	].
]

{ #category : #'printing & storing' }
AcAsmOperandModifier class >> unparseOn: aStream [
	"See AcAsmFormatChunk >> #unparseOn:"
	aStream nextPut: $(.
	aStream nextPutAll: self name asLowercase.
	aStream nextPut: $).

]

{ #category : #API }
AcAsmOperandModifier >> encode: value inFields: fs accordingTo: format [
	^ fs isMultiField
		ifTrue: [ fs encodeComplexValue: value accordingTo: format ]
		ifFalse: [ fs encodeSimpleValue: value ]
]

{ #category : #API }
AcAsmOperandModifier >> encodeInFields: fs accordingTo: format [
	self subclassResponsibility 
]

{ #category : #accessing }
AcAsmOperandModifier >> x [
	^ x
]

{ #category : #accessing }
AcAsmOperandModifier >> x: anObject [
	x := anObject
]
