Class {
	#name : #OpcodeDecoder,
	#superclass : #Object,
	#instVars : [
		'instrGroups',
		'opcodeRange'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
OpcodeDecoder class >> for: aPDL [
	| instance allInstructions opcodeRange knownOpcodes bunches |
	instance := self basicNew.
	opcodeRange := self opcodePositionIn: aPDL.
	allInstructions := aPDL instructions values collect: [ :inst |
		| opcd |
		opcd := inst binaryEncoding subrange: opcodeRange.
		opcd value -> inst ].
	"now bunch them by opcode"
	knownOpcodes := (allInstructions collect: #key) asSet.
	bunches := Dictionary new.
	knownOpcodes do: [ :opcd | bunches at: opcd put: Bag new ].
	allInstructions do: [ :one |
		(bunches at: one key) add: one value ].
	^instance
		instrGroups: bunches;
		opcodeRange: opcodeRange;
		yourself
]

{ #category : #'as yet unclassified' }
OpcodeDecoder class >> opcodePositionIn: aPDL [
	| anyFmt range |
	anyFmt := aPDL instructionFormats values anyOne.
	range := anyFmt opcdFieldInterval.
	"double-check that all formats agree where the opcode is"
	aPDL instructionFormats detect: [ :f | f opcdFieldInterval ~= range ] ifFound: [ self error ].
	^range
]

{ #category : #accessing }
OpcodeDecoder >> instrGroups [
	^ instrGroups
]

{ #category : #accessing }
OpcodeDecoder >> instrGroups: anObject [
	instrGroups := anObject
]

{ #category : #'as yet unclassified' }
OpcodeDecoder >> instructionsWithOpcodeFitting: instrBinary [
	| opcd |
	opcd := instrBinary subrange: opcodeRange.
	^instrGroups at: opcd value 
]

{ #category : #'as yet unclassified' }
OpcodeDecoder >> opcodeRange [
	^opcodeRange
]

{ #category : #'as yet unclassified' }
OpcodeDecoder >> opcodeRange: anInterval [
	opcodeRange := anInterval
]
