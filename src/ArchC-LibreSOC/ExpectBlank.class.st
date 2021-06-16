Class {
	#name : #ExpectBlank,
	#superclass : #ParsingState,
	#instVars : [
		'nextState'
	],
	#category : #'ArchC-LibreSOC'
}

{ #category : #'as yet unclassified' }
ExpectBlank class >> op: op next: aParserStateSubclass [ 
	^super new
		op: op;
		nextState: aParserStateSubclass;
		yourself
]

{ #category : #accessing }
ExpectBlank >> nextState [
	^ nextState
]

{ #category : #accessing }
ExpectBlank >> nextState: anObject [
	nextState := anObject
]

{ #category : #logic }
ExpectBlank >> transition: l [
	l isEmpty ifFalse: [ self error ].
	^nextState new: op
]
