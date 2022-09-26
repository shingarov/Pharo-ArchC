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
	| alternativeParsers defaultInt mappings |
	defaultInt := nil.
	mappings := self map forwardMap associations.
	"
	Sort mappings by descending key length. This is needed
	for cases where one key may be prefix of another. This
	way, longer keys are tried before shorter.
	"
	mappings sort: [ :a :b | a key size > b key size ].

	alternativeParsers := mappings collect: [ :ass |
		| sym i |
		i := ass value.
		sym := ass key.
		sym isEmpty
			ifTrue: [ defaultInt:= i. nil ]
			ifFalse: [ sym asParser ==> [ :x | i ] ]].
	alternativeParsers := alternativeParsers asOrderedCollection.
	alternativeParsers remove: nil ifAbsent: [ #NoEmpty ].
	alternativeParsers := PPChoiceParser withAll: alternativeParsers.
	defaultInt isNil ifFalse: [ alternativeParsers :=
		alternativeParsers optional ==> [ :x | x ifNil: [defaultInt] ] ] .
	^alternativeParsers / self immExpression  ==> [ :x | { NoOperandModifier new x: x; yourself } ]
]

{ #category : #'API - disassembly' }
AcAsmFormatMapChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: aDictionary [
	| op value |

	ops isEmpty ifTrue: [ ^ false ].
	op := ops removeFirst operand.
	value := aDictionary at: op.
	(value isAST and:[value isSymbolic]) ifTrue: [
		| symbol |

		symbol := value sym.
		aWriteStream nextPut: ${;  nextPutAll: symbol; nextPut: $}.
	] ifFalse: [ 
		| name |

		name := (self map backLookup: value ifAbsent:[^ false]) name.
		aWriteStream nextPutAll: name
	].
	^ true
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
