Class {
	#name : #IslaRegister,
	#superclass : #IslaParagraph,
	#instVars : [
		'name',
		'type'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
IslaRegister class >> name: n type: t [
	^self basicNew name: n; type: t; yourself 
]

{ #category : #compilation }
IslaRegister >> analyzeContextFor: aKluiver [ 
	program := aKluiver.
	aKluiver registers at: name put: (type analyzeContextFor: program)

]

{ #category : #accessing }
IslaRegister >> name: anObject [
	name := anObject
]

{ #category : #accessing }
IslaRegister >> type [
	^ type
]

{ #category : #accessing }
IslaRegister >> type: anObject [
	type := anObject
]
