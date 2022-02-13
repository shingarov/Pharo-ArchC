Class {
	#name : #IslaVal,
	#superclass : #IslaParagraph,
	#instVars : [
		'name',
		'description',
		'type'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
IslaVal class >> name: n description: d type: t [ 
	^self basicNew name: n; description: d; type: t; yourself 
]

{ #category : #'as yet unclassified' }
IslaVal >> analyzeContextFor: aKluiver [ 
	aKluiver funTypes at: name put: (type analyzeContextFor: aKluiver).
	aKluiver funDescriptions at: name put: description 
]

{ #category : #accessing }
IslaVal >> description [
	^ description
]

{ #category : #accessing }
IslaVal >> description: anObject [
	description := anObject
]

{ #category : #accessing }
IslaVal >> name [
	^ name
]

{ #category : #accessing }
IslaVal >> name: anObject [
	name := anObject
]

{ #category : #accessing }
IslaVal >> type [
	^ type
]

{ #category : #accessing }
IslaVal >> type: anObject [
	type := anObject
]
