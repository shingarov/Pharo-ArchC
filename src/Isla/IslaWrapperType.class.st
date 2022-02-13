Class {
	#name : #IslaWrapperType,
	#superclass : #Object,
	#instVars : [
		'elementType'
	],
	#category : #Isla
}

{ #category : #accessing }
IslaWrapperType class >> elementType: t [
	^self basicNew elementType: t; yourself
]

{ #category : #accessing }
IslaWrapperType >> elementType [
	^ elementType
]

{ #category : #accessing }
IslaWrapperType >> elementType: anObject [
	elementType := anObject
]
