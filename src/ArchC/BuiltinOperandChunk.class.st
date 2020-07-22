Class {
	#name : #BuiltinOperandChunk,
	#superclass : #AcMnemonicChunk,
	#instVars : [
		'type',
		'modifier'
	],
	#category : #'ArchC-Core'
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
	^self hexImmLiteral / self decImmLiteral 
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
