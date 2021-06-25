"
I am a CPU instruction.
I may be grounded to some degree or another -- i.e., some operands known and some not.
When the PDL spec is initially parsed, the ""instrictions"" Dictionary is filled with ""fully free"" instructions, i.e. only the constant fields (such as opcd) are known but none of the operands.  This does not, however, prevent the instruction from being emitted; if some operand is unknown, the corresponding bits in the binary encoding will be an algebraic variable.
"
Class {
	#name : #ProcessorInstruction,
	#superclass : #ProcessorInstructionDeclaration,
	#instVars : [
		'binaryEncoding'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #comparing }
ProcessorInstruction >> = another [
	self == another ifTrue: [^true].
	self class = another class ifFalse: [^false].
	^self binaryEncoding = another binaryEncoding
]

{ #category : #access }
ProcessorInstruction >> allBindingValues [
	| allBindings |
	allBindings := format bitFieldNames
		reject: [ :fieldName | fieldName isInteger ]
		thenCollect: [ :fieldName | fieldName -> (self fieldValue: fieldName) ].
	^Dictionary newFromAssociations: allBindings 


]

{ #category : #access }
ProcessorInstruction >> allBindings [
	| allBindings |
	allBindings := format bitFieldNames collect: [ :fieldName |
		fieldName -> (self field: fieldName) simplify].
	^Dictionary newFromAssociations: allBindings 


]

{ #category : #solving }
ProcessorInstruction >> alwaysFitsBinary: aBV [
	| encodingIsCorrect myUnknowns solver answer |
	encodingIsCorrect := self binaryEncoding eq: aBV.
	myUnknowns := self binaryEncoding variables asArray.
	myUnknowns isEmpty ifFalse: [encodingIsCorrect := encodingIsCorrect exists: myUnknowns].
	solver := Z3Solver new.
	answer := [solver proveValid: encodingIsCorrect. true]
		on: NotValid do: [false].
	solver del.
	^answer
]

{ #category : #access }
ProcessorInstruction >> binaryEncoding [
	binaryEncoding isNil ifTrue: [ self initializeBinaryEncoding ].
	^binaryEncoding
]

{ #category : #private }
ProcessorInstruction >> binaryEncoding: anInt [
	binaryEncoding := anInt
]

{ #category : #solving }
ProcessorInstruction >> canFitBinary: aBV [
	| solver answer |
	solver := Z3Solver new.
	solver assert: (self binaryEncoding eq: aBV).
	answer := solver check.
	solver del.
	^answer
]

{ #category : #disassembly }
ProcessorInstruction >> disassemble [
	| variants |
	variants := mnemonics collect: [ :mnem |
		mnem disassembleEnv: self allBindingValues ].
	variants := variants reject: [ :v | v isNil ].
	variants := variants sorted: [ :a :b | a value > b value ].
	^variants first key
]

{ #category : #emitting }
ProcessorInstruction >> emit32 [
	"Just making mischief.
	Some not-so-nice ISAs do not allow this (not that I care)."
	format binaryEncoding length = 32 ifFalse: [ self error: 'Instruction size not 32' ].
	^self binaryEncoding value
]

{ #category : #disassembly }
ProcessorInstruction >> externalBindingValues [
	^Dictionary newFromAssociations: (self externalBindings collect: [ :ass | ass key -> (self fieldValue: ass key) ])

]

{ #category : #disassembly }
ProcessorInstruction >> externalBindings [
	"Answer ..."
	^format bitFields select: [ :ass |
		(ass key isString and: (internalBindings includesKey: ass key) not)]
]

{ #category : #access }
ProcessorInstruction >> field: fieldName [
	"Answer the value of the requested field, as a bit vector."
	^self binaryEncoding subrange: (self rangeOf: fieldName)
]

{ #category : #access }
ProcessorInstruction >> fieldValue: fieldName [
	"Answer the value of the requested field, as an Integer
	(observing two's complement if required)."
	| bitVector |
	bitVector := (self field: fieldName) simplify.
	^(format isSigned: fieldName)
		ifTrue: [ bitVector signedValue ]
		ifFalse: [ bitVector value ]
]

{ #category : #private }
ProcessorInstruction >> initializeBinaryEncoding [
	binaryEncoding := self leastKnownBinary
]

{ #category : #LWISEM }
ProcessorInstruction >> instantiateLWISEM: aString [ 
	"First, substitute uninterpreted fields."
	^(aString replaceKeywords: [ :key | (self field: key) representSmalltalkInPython ])
	"Then, substitute field values"
	replaceValueKeywords: [ :key | (self fieldValue: key) representSmalltalkInPython ]
]

{ #category : #semantics }
ProcessorInstruction >> printLogicOn: aStream [
	semantics ifNil: [ ^self ].
	semantics do: [ :sem | sem printLogicOn: aStream. aStream cr; cr ]
]

{ #category : #printing }
ProcessorInstruction >> printOn: aStream [ 
	aStream nextPutAll: (self name); nextPutAll: ': '.
	aStream nextPutAll: self disassemble.

]

{ #category : #access }
ProcessorInstruction >> semantics [
	semantics isNil ifTrue: [
		"This is needed even though the instance is created
		eagerly during DSL parsing.  This is a dirty hack."
		semantics := #LwInstructionSemantics instruction: self.
		^semantics  ].
	^semantics copy
		instruction: self;
		yourself 
]

{ #category : #emitting }
ProcessorInstruction >> substitute: operandDictionary [
	"Answer a copy of myself with those operands in operandDictionary replaced by new values"
	
	| operandValues |
	operandValues := self externalBindingValues.
	operandValues addAll: operandDictionary.
	^self inEnvironment: operandValues
]

{ #category : #VEX }
ProcessorInstruction >> vezAt: addr [
	^self semantics liftStartingAt: addr
]
