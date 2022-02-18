Class {
	#name : #AcAsmFormatMapChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'name',
		'instruction'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmFormatMapChunk class >> map: aDictionary named: nameString source: sourceString [
	^super new
		map: aDictionary;
		name: nameString;
		source: sourceString;
		yourself
]

{ #category : #'API - assembly' }
AcAsmFormatMapChunk >> assembler [ 
	| alternativeParsers nilForEmptySym defaultInt |
	defaultInt := nil.
	alternativeParsers := self map forwardMap associations  collect: [ :ass |
		| sym i |
		i := ass value.
		sym := ass key.
		sym isEmpty
			ifTrue: [ defaultInt:= i. nil ]
			ifFalse: [ sym asParser ==> i K ]].
	alternativeParsers := alternativeParsers asOrderedCollection.
	nilForEmptySym := alternativeParsers remove: nil ifAbsent: [ #NoEmpty ].
	alternativeParsers := PPChoiceParser withAll: alternativeParsers.
	defaultInt isNil ifFalse: [ alternativeParsers :=
		alternativeParsers optional ==> [ :x | x ifNil: [defaultInt] ] ] .
	^alternativeParsers / self immExpression  ==> [ :x | { NoOperandModifier new x: x; yourself } ]

]

{ #category : #'API - disassembly' }
AcAsmFormatMapChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: aDictionary [
	| op value symbolic |
	op := ops removeFirst operand.
	value := aDictionary at: op.
	symbolic := (self map backLookup: value) name.
	aWriteStream nextPutAll: symbolic
]

{ #category : #accessing }
AcAsmFormatMapChunk >> instruction: aProcessorInstructionDeclaration [
	instruction := aProcessorInstructionDeclaration
]

{ #category : #testing }
AcAsmFormatMapChunk >> isMapChunk [
	^ true
]

{ #category : #accessing }
AcAsmFormatMapChunk >> map [
	| maps |

	instruction notNil ifTrue: [ 
		maps := instruction isa maps
	] ifFalse: [ 
		"  This is a super-ugly hack for backward compatibility"
		maps := AcAsmFormatParser maps
	].
	^ maps at: name ifAbsent: [ self error: 'No map named ' , name ]

]

{ #category : #accessing }
AcAsmFormatMapChunk >> name [
	^ name
]

{ #category : #accessing }
AcAsmFormatMapChunk >> name: anObject [
	name := anObject
]

{ #category : #'printing & storing' }
AcAsmFormatMapChunk >> unparseOn: aStream [
	aStream nextPut: $%; nextPut: $[.
	aStream nextPutAll: name.
	aStream nextPut: $].
]
