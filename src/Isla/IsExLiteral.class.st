Class {
	#name : #IsExLiteral,
	#superclass : #IsEx,
	#instVars : [
		'literal'
	],
	#category : #Isla
}

{ #category : #accessing }
IsExLiteral class >> literal: l [
	^self basicNew literal: l; yourself 
]

{ #category : #accessing }
IsExLiteral >> literal [
	^ literal
]

{ #category : #accessing }
IsExLiteral >> literal: anObject [
	literal := anObject
]

{ #category : #printing }
IsExLiteral >> printOn: aStream [
	literal printOn: aStream
]
