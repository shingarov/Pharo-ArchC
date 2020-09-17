Class {
	#name : #BuiltinOperandChunk,
	#superclass : #AcMnemonicChunk,
	#instVars : [
		'type',
		'modifier'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
BuiltinOperandChunk class >> type: aNameSuchAsImm modifier: aClass [
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
BuiltinOperandChunk >> assembler [
	^self immLiteral / self immExpression ==> [ :x | modifier new x: x; yourself ]
]

{ #category : #'parsing - private' }
BuiltinOperandChunk >> decImmLiteral [
	^#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ]
]

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	| op |
	op := ops removeFirst.
	self modifier disassemble: op to: aWriteStream inEnvironment: e format: self instruction format
]

{ #category : #'parsing - private' }
BuiltinOperandChunk >> hexImmLiteral [
	^'0x' asParser, #digit asParser plus flatten ==> [ :prefAndnumeral | Integer readFrom: prefAndnumeral second  base: 16 ]
]

{ #category : #'parsing - private' }
BuiltinOperandChunk >> immLiteral [
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
BuiltinOperandChunk >> modifier [
	^ modifier
]

{ #category : #accessing }
BuiltinOperandChunk >> modifier: anObject [
	modifier := anObject
]

{ #category : #accessing }
BuiltinOperandChunk >> type [
	^ type
]

{ #category : #accessing }
BuiltinOperandChunk >> type: anObject [
	type := anObject
]
