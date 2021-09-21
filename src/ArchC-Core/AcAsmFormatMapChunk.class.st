Class {
	#name : #AcAsmFormatMapChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'map',
		'name',
		'source'
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
	alternativeParsers := map forwardMap associations  collect: [ :ass |
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
		alternativeParsers optional ==> [ :x | x ifNil: [defaultInt] ] ].
	^alternativeParsers / self immExpression  ==> [ :x | NoOperandModifier new x: x; yourself ]
]

{ #category : #'API - disassembly' }
AcAsmFormatMapChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: aDictionary [
	| op v symbolic |
	op := ops removeFirst operand.
	v := aDictionary at: op.
	symbolic := self map backLookup: v.
	aWriteStream nextPutAll: symbolic
]

{ #category : #accessing }
AcAsmFormatMapChunk >> map [
	^ map
]

{ #category : #accessing }
AcAsmFormatMapChunk >> map: anObject [
	map := anObject
]

{ #category : #accessing }
AcAsmFormatMapChunk >> name [
	^ name
]

{ #category : #accessing }
AcAsmFormatMapChunk >> name: anObject [
	name := anObject
]

{ #category : #accessing }
AcAsmFormatMapChunk >> source [
	^ source
]

{ #category : #accessing }
AcAsmFormatMapChunk >> source: anObject [
	source := anObject
]
