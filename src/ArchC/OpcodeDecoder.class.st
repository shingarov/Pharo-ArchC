Class {
	#name : #OpcodeDecoder,
	#superclass : #Object,
	#instVars : [
		'instrGroups',
		'opcodeRange'
	],
	#category : #'ArchC-Core'
}

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
