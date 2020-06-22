Class {
	#name : #PercentAcMnemonicChunk,
	#superclass : #AcMnemonicChunk,
	#instVars : [
		'map',
		'name',
		'source'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
PercentAcMnemonicChunk class >> map: aDictionary named: nameString source: sourceString [
	^super new
		map: aDictionary;
		name: nameString;
		source: sourceString;
		yourself
]

{ #category : #'API - assembly' }
PercentAcMnemonicChunk >> assembler [ 
	| alternativeParsers nilForEmptySym defaultInt |
	defaultInt := nil.
	alternativeParsers := map forwardMap associations  collect: [ :ass |
		| sym i |
		i := ass value.
		sym := ass key.
		sym isEmpty
			ifTrue: [ defaultInt:= i. nil ]
			ifFalse: [ sym asParser ==> [ :_ | i ] ]].
	alternativeParsers := alternativeParsers asOrderedCollection.
	nilForEmptySym := alternativeParsers remove: nil ifAbsent: [ #NoEmpty ].
	alternativeParsers := PPChoiceParser withAll: alternativeParsers.
	defaultInt isNil ifFalse: [ alternativeParsers :=
		alternativeParsers optional ==> [ :x | x ifNil: [defaultInt] ] ].
	^alternativeParsers / self immExpression 
]

{ #category : #'API - disassembly' }
PercentAcMnemonicChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: aDictionary [
	| op v symbolic |
	op := ops removeFirst operand.
	v := aDictionary at: op.
	symbolic := self map backLookup: v.
	aWriteStream nextPutAll: symbolic
]

{ #category : #accessing }
PercentAcMnemonicChunk >> map [
	^ map
]

{ #category : #accessing }
PercentAcMnemonicChunk >> map: anObject [
	map := anObject
]

{ #category : #accessing }
PercentAcMnemonicChunk >> name [
	^ name
]

{ #category : #accessing }
PercentAcMnemonicChunk >> name: anObject [
	name := anObject
]

{ #category : #accessing }
PercentAcMnemonicChunk >> source [
	^ source
]

{ #category : #accessing }
PercentAcMnemonicChunk >> source: anObject [
	source := anObject
]
