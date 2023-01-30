"
A builtin - either `%imm` (unsigned numeric value) or `%exp` (signed numeric value)
with optional modifier - see `AcAsmOperandModifier`.

"
Class {
	#name : #AcAsmFormatBuiltinChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'type',
		'modifier',
		'instruction'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'API - assembly' }
AcAsmFormatBuiltinChunk >> assembler [
	| assembler |
	(modifier notNil and: [ modifier isPCREL ]) ifTrue: [
		assembler := self pcrelLiteral / self pcrelExpression
	] ifFalse: [ 
		assembler := self immLiteral / self immExpression
	].

	^ assembler ==> [ :x | { modifier new x: x; yourself } ]
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> decImmLiteral [
	^#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ]
]

{ #category : #'API - disassembly' }
AcAsmFormatBuiltinChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [ 
	| op |

	ops isEmpty ifTrue: [ ^ false ].
	op := ops removeFirst.
	self modifier 
		disassemble: op
		to: aWriteStream
		inEnvironment: e
		format: instruction format
		chunk: self.
	^ true
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> gasLabel [
	"Parse GNU assembler style label. 

	 See https://sourceware.org/binutils/docs/as/Labels.html
	"
	| first rest |

	first := ($_ asParser / $. asParser / $$ asParser / #letter asParser).
	rest  := ($_ asParser / $. asParser / $$ asParser / #letter asParser / #digit asParser) star.
	^ (first, rest) token ==> [ :token | token inputValue ]

	"
	(AcAsmFormatBuiltinChunk new gasLabel parse: '.l_99')
	"
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> hexImmLiteral [
	^'0x' asParser, #hex asParser plus flatten ==> [ :prefAndnumeral | Integer readFrom: prefAndnumeral second  base: 16 ]

]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> immLiteral [
	| il |
	il := self hexImmLiteral / self decImmLiteral.
	self type = '%exp' ifTrue: [ 
		"There is a subtle difference between %imm and %exp:
		in a numeral like -123, the minus is part of %exp but
		is treated as external to %imm"
		il := $- asParser optional, il ==> 	[ :x |
			| abs |
			abs := x second.
			x first isNil
				ifTrue: [ abs ]
				ifFalse: [ abs negated ]]].
	^il
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> instruction: aProcessorInstructionDeclaration [
	instruction := aProcessorInstructionDeclaration
]

{ #category : #testing }
AcAsmFormatBuiltinChunk >> isBuiltinChunk [
	^ true
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> modifier [
	^ modifier
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> modifier: anObject [
	modifier := anObject
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> pcrelExpression [
	"As a convenience allow PC-relative symbolic values be written also
	 as (GNU) assembler labels in addition to usual curly-braces syntax."

	^ self gasLabel / self immExpression

	"
	(AcAsmFormatBuiltinChunk new pcrelExpression parse: '.l_99')
	(AcAsmFormatBuiltinChunk new pcrelExpression parse: 'some_label')
	(AcAsmFormatBuiltinChunk new pcrelExpression parse: '{some_label}')
	(AcAsmFormatBuiltinChunk new pcrelExpression parse: '{a+b}')
	(AcAsmFormatBuiltinChunk new pcrelExpression parse: 'a+b')
	"
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> pcrelLiteral [
	^ self immLiteral
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> type [
	^ type
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> type: aString [
	self assert: (self class builtins includes: aString).
	type := aString
]

{ #category : #'printing & storing' }
AcAsmFormatBuiltinChunk >> unparseOn: aStream [
	"Print this chunk on `aStream` using the syntax recognized by AcAsmFormatParser."

	aStream nextPutAll: type.
	modifier unparseOn: aStream.
]
