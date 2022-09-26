Class {
	#name : #AcAsmSyntax,
	#superclass : #Object,
	#instVars : [
		'source',
		'instruction',
		'format',
		'operands',
		'constraints'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmSyntax class >> format: aMnemonicFormat operandsAndConstraints: anArray [
	| operands constraints |

	operands := OrderedCollection new.
	constraints := Dictionary new.
	"Generally speaking, anArray will contain a mixture of operand names (Strings)
	 and constraints which are operands pre-bound to values and therefore Associations."
	anArray do: [:each | 
		(each isKindOf: Association) ifTrue: [ 
			constraints add: each
		] ifFalse: [ 
			operands add: each
		].
	].

	^self new
		format: aMnemonicFormat;
		operands: operands;
		constraints: constraints;
		yourself
]

{ #category : #'API - assembly' }
AcAsmSyntax >> assembler [
	"Construct a parser which will parse the actual
	assembly statements."
	| parser |
	parser := self format assembler.
	^parser end ==> [ :actualOperandsFromChunks |
		| actualOperands allOperands fieldValues |
		actualOperands := actualOperandsFromChunks reject: #isNil.
		actualOperands := Dictionary newFromKeys: self operands andValues: actualOperands.
		allOperands := actualOperands copy addAll: constraints; yourself.
		fieldValues := Dictionary new.
		allOperands keysAndValuesDo: [ :opDef :v |
				fieldValues addAll: (opDef asOperandInstantiation encodeValue: v accoringTo: instruction format) ].
		self instruction inEnvironment: fieldValues ]

]

{ #category : #accessing }
AcAsmSyntax >> constraints [
	^ constraints
]

{ #category : #accessing }
AcAsmSyntax >> constraints: anObject [
	constraints := anObject
]

{ #category : #'API - disassembly' }
AcAsmSyntax >> constraintsSatisfiedBy: aDictionary [
	"Answer whether the operand valuation given by aDictionary,
	satisfies the constraints of this syntactic form.
	Note that aDictionary MUST include everything in <constraints>."
	constraints associationsDo: [ :constraint |
		| thisValuation |
		thisValuation := aDictionary at: constraint key ifAbsent: [ nil ].
		thisValuation = constraint value ifFalse: [ ^false ] ].
	^true

]

{ #category : #'API - disassembly' }
AcAsmSyntax >> disassembleEnv: aDictionary [
	"Given the operand environment aDictionary,
	 answer a string of disassembly, or nil if
	 the environment does not fit this spec.
	 The answer is given in the form of Association,
	 whose key is the string of disassembly and the
	 value is an integer indicating the number of 
	 bound operands.  The latter is used to select
	 the most sepecific mnemonic form.
	OPERAND VALUES IN aDictionary MUST BE CONCRETE."
	
	| stream operandsToDisassemble |
	(self constraintsSatisfiedBy: aDictionary) ifFalse: [ ^nil ].
	operandsToDisassemble := operands asOrderedCollection copy.
	stream := WriteStream on: String new.
	(self format disassembleTo: stream operands: operandsToDisassemble inEnvironment: aDictionary) ifFalse: [ 
		^ nil
	].
	^stream contents
]

{ #category : #accessing }
AcAsmSyntax >> format [
	format isString ifTrue: [ 
		format := AcAsmFormatParser parse: format.
		format do: [:each | each instruction: instruction ]
	].
	^ format

]

{ #category : #accessing }
AcAsmSyntax >> format: anObject [
	format := anObject.
	format isString ifFalse: [ 
		format instruction: instruction
	].

]

{ #category : #accessing }
AcAsmSyntax >> instruction [
	^ instruction
]

{ #category : #accessing }
AcAsmSyntax >> instruction: i [
	instruction := i.
	format isString ifFalse: [ 
		format instruction: instruction
	].  

]

{ #category : #testing }
AcAsmSyntax >> isMoreOrEquallySpecificThan: another [ 
	self format operands size < another format operands size ifTrue: [
		^ true
	].
	self format operands size = another format operands size ifTrue: [
		self constraints size >= another constraints size ifTrue: [
			^ true
		].
	].
	^ false
]

{ #category : #accessing }
AcAsmSyntax >> mnemonics [
	"Return all mnemonics (as array of strings) defined by this format. 
	 See AcAsmFormat >> #mnemonicsInto: for details."

	| mnemonics |

	mnemonics := Set new.
	self mnemonicsInto: mnemonics.
	^ mnemonics

	"
	((AcProcessorDescriptions reset; armv5) instructionAt: 'add1') mnemonics
	((AcProcessorDescriptions reset; riscv) instructionAt: 'addi') mnemonics
	"
]

{ #category : #accessing }
AcAsmSyntax >> mnemonicsInto: aSet [
	format mnemonicsInto: aSet
]

{ #category : #accessing }
AcAsmSyntax >> operands [
	^ operands
]

{ #category : #accessing }
AcAsmSyntax >> operands: anArray [
	
	operands := anArray 
]

{ #category : #printing }
AcAsmSyntax >> printOn: aStream [
	aStream nextPutAll: (self source ifNil: [ 'AcSetAsm (no source)' ])
]

{ #category : #accessing }
AcAsmSyntax >> source [
	^ source
]

{ #category : #accessing }
AcAsmSyntax >> source: anObject [
	source := anObject
]
