Class {
	#name : #ParsingState,
	#superclass : #Object,
	#instVars : [
		'op'
	],
	#category : #'ArchC-LibreSOC'
}

{ #category : #'instance creation' }
ParsingState class >> new: op [
	^super new 
		op: op;
		yourself
]

{ #category : #'as yet unclassified' }
ParsingState >> isAccepting [
	^false
]

{ #category : #accessing }
ParsingState >> op [
	^ op
]

{ #category : #accessing }
ParsingState >> op: anObject [
	op := anObject
]

{ #category : #logic }
ParsingState >> transition: l [
	self subclassResponsibility 
]
