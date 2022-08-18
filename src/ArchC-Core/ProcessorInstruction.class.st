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

{ #category : #converting }
ProcessorInstruction >> asByteArray [
	"Return bytes encoding this instruction. The instruction
	 must be fully grounded (that is: not symbolic) otherwise 
	 an error is thrown.
	"
	^ ByteArray streamContents: [ :s | self emitOn: s ]

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
	variants := self syntax collect: [ :each | each disassembleEnv: self allBindingValues ].
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

{ #category : #emitting }
ProcessorInstruction >> emitOn: aStream [
	"Emit (encode) instruction on given (binary) stream. The instruction
	 must be fully grounded (that is: not symbolic) otherwise an error is
	 thrown.
	"
	self binaryEncoding toByteArrayEndian: isa endian on: aStream
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

{ #category : #inspecting }
ProcessorInstruction >> inspectorExtraAttributes [
	"Smalltalk/X inspector extras"
	| attrs |

	attrs := super inspectorExtraAttributes.
	attrs at: '-encoding' put: (String streamContents: [:s | self printEncodingOn: s]).
	^attrs

]

{ #category : #printing }
ProcessorInstruction >> printEncodingOn: aStream [
	| bin idx |

	bin := String streamContents:[:b|self emit32 printOn:b paddedWith:$0 to:32 base:2].

	idx := 0.
	format bitFields do:[:field |
		aStream nextPutAll: (bin copyFrom: idx + 1 to: idx + field value abs).
		aStream space.
		idx := idx + field value abs
	].
	aStream cr.
	format bitFields do:[:field |
		| fieldName |

		fieldName := (field key size > field value abs) 
						ifTrue:[field key copyFrom: 1 to: field value abs]
						ifFalse:[ field key ].
		aStream nextPutAll: fieldName.
		aStream next: field value abs - fieldName size put: Character space.
		aStream space.
	].
]

{ #category : #printing }
ProcessorInstruction >> printOn: aStream [ 
	aStream nextPutAll: (self name); nextPutAll: ': '.
	aStream nextPutAll: self disassemble.

]
