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
	#category : #'ArchC-Core'
}

{ #category : #comparing }
ProcessorInstruction >> = another [
	^self == another or: [ self binaryEncoding = another binaryEncoding ]
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

{ #category : #access }
ProcessorInstruction >> binaryEncoding [
	binaryEncoding isNil ifTrue: [ self initializeBinaryEncoding ].
	^binaryEncoding
]

{ #category : #private }
ProcessorInstruction >> binaryEncoding: anInt [
	binaryEncoding := anInt
]

{ #category : #emitting }
ProcessorInstruction >> bindSequence: seq [
	"The operands of an instruction are ordered.
	Answer a GroundedProcessorInstruction whose first operand is bound to (seq first), and so on."
	| allFields operandFields env |
self shouldBeImplemented.
	allFields := format bitFields.
	operandFields := allFields reject: [ :ass | internalBindings includesKey: ass key ].
	operandFields := operandFields reject: [ :ass | ass key isInteger ].
	seq size == operandFields size ifFalse: [
		self error: 'Instruction ', name, ' takes ', operandFields size, ' operands but we are given ', seq size printString  ].
	env := Dictionary new.
	operandFields doWithIndex: [ :field :i |
		| operandValue |
		operandValue := seq at: i.
		"operandValue < (1<<field value abs) ifFalse: [ self halt; error: 'Operand value ', operandValue printString, ' does not fit in ', field value printString, ' bits' ]."
		env at: field key put: operandValue.
		 ].
	^self bind: env
]

{ #category : #private }
ProcessorInstruction >> copyWithBinary: aBinaryEncoding [
	^self copy
		binaryEncoding: aBinaryEncoding;
		yourself 
	
]

{ #category : #disassembly }
ProcessorInstruction >> decode: aBV [
	"Answer a copy of the receiver concretized down to be
	consistent with the binary encoding given by aBV.
	Answer nil if this is impossible, -- e.g., if the opcode
	contained in aBV is different from the receiver's opcode.
	
	The most straightforward scenario is when the receiver
	is an instruction declaration (i.e. none of the operands
	are known) and the argument is concrete (non-symbolic),
	resulting in a fully-grounded instruction; but this does
	not *necessarily* have to be the only possible scenario:
	some operands could be known already, and aBV could
	contain some unknown bits."
	
	| operandFields |
	(self fitsBinary: aBV) ifFalse: [ ^nil ].
	^self copyWithBinary: aBV
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
ProcessorInstruction >> externalBindingBits [
	"Answer the total number of bits in external-bound operands.
	This does NOT mean operands whose value we don't yet know,
	e.g. an RA register-number operand is still external even if
	we may already know which register it is."
	| sum |
	sum := 0.
	format bitFields do: [ :ass |
		(ass key isString and: (internalBindings includesKey: ass key) not) ifTrue: [ sum := sum + ass value abs ]].
	^sum
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

{ #category : #GT }
ProcessorInstruction >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 20>
	composite morph
		title: 'Bit fields';
		morph: [ InstructionMorph on: self ]
]

{ #category : #emitting }
ProcessorInstruction >> inEnvironment: env [
	"Answer a ProcessorInstruction where the operands are bound according to env.
	It is not necessary to define values for ALL operands; if some operands are
	left unspecified, those bits in the emitted binary will be symbolic.
	NB: unlike #decode: which returns a model, this method's answer is the most general."
	^self copyWithBinary: (self binaryEncoding inEnvironment: env)
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

{ #category : #private }
ProcessorInstruction >> leastKnownBinary [
	^self format binaryEncoding inEnvironment: self internalBindings
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
ProcessorInstruction >> rangeOf: fieldName [
	"Answer the interval of bit-positions of the requested field."
	| start stop |
	start := format positionOf: fieldName.
	stop := start + 1 - (format widthOf: fieldName).
	^Interval from: start to: stop by: -1
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

{ #category : #VEX }
ProcessorInstruction >> vezAt: addr [
	^self semantics liftStartingAt: addr
]
