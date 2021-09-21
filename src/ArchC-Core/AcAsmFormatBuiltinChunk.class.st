Class {
	#name : #AcAsmFormatBuiltinChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'type',
		'modifier'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmFormatBuiltinChunk class >> type: aNameSuchAsImm modifier: aClass [
	(((aNameSuchAsImm = '%imm')
		or: [aNameSuchAsImm = '%exp'])
		or: [aNameSuchAsImm = '%addr'])
	ifFalse: [ self error: 'Cant happen' ].
	^super new
		type: aNameSuchAsImm;
		modifier: aClass;
		yourself
]

{ #category : #'API - assembly' }
AcAsmFormatBuiltinChunk >> assembler [
	^self immLiteral / self immExpression ==> [ :x | modifier new x: x; yourself ]
]

{ #category : #'parsing - private' }
AcAsmFormatBuiltinChunk >> decImmLiteral [
	^#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ]
]

{ #category : #'API - disassembly' }
AcAsmFormatBuiltinChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	| op |
	op := ops removeFirst.
	self modifier disassemble: op to: aWriteStream inEnvironment: e format: self instruction format
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
AcAsmFormatBuiltinChunk >> modifier [
	^ modifier
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> modifier: anObject [
	modifier := anObject
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> type [
	^ type
]

{ #category : #accessing }
AcAsmFormatBuiltinChunk >> type: anObject [
	type := anObject
]
