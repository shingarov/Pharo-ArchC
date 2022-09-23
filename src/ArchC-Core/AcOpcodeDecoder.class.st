Class {
	#name : #AcOpcodeDecoder,
	#superclass : #AcInstructionDecoder,
	#instVars : [
		'instrGroups',
		'opcodeRange'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'as yet unclassified' }
AcOpcodeDecoder class >> opcodePositionIn: aPDL [
	| range |
	range := aPDL opcdFieldInterval.
	"double-check that all formats agree where the opcode is"
	self assert: (aPDL instructionFormats allSatisfy: [ :f | f opcdFieldInterval = range ]).
	^range

]

{ #category : #initialization }
AcOpcodeDecoder >> initializeWithPDL: aPDL [
	| allInstructions knownOpcodes bunches |

	super initializeWithPDL: aPDL.
	allInstructions := aPDL instructions values collect: [ :inst | inst opcode -> inst ].
	"now bunch them by opcode"
	knownOpcodes := (allInstructions collect: #key) asSet.
	bunches := Dictionary new.
	knownOpcodes do: [ :opcd | bunches at: opcd put: Bag new ].
	allInstructions do: [ :one |
		(bunches at: one key) add: one value ].

	instrGroups := bunches.
	opcodeRange := self class opcodePositionIn: aPDL
]

{ #category : #decoding }
AcOpcodeDecoder >> preDecodeBits: aBitVector [ 
	| opcd |

	opcd := aBitVector subrange: opcodeRange.
	^ instrGroups at: opcd value
		ifAbsent: [ IllegalInstruction signalWith: aBitVector ]
]
