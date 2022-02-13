Class {
	#name : #IsExApplication,
	#superclass : #IsEx,
	#instVars : [
		'functor',
		'args'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
IsExApplication class >> functor: f args: aa [
	^self basicNew functor: f; args: aa; yourself 
]

{ #category : #accessing }
IsExApplication >> args [
	^ args
]

{ #category : #accessing }
IsExApplication >> args: anObject [
	args := anObject
]

{ #category : #accessing }
IsExApplication >> functor [
	^ functor
]

{ #category : #accessing }
IsExApplication >> functor: anObject [
	functor := anObject
]

{ #category : #printing }
IsExApplication >> printOn: aStream [
	aStream nextPutAll: functor.
	aStream nextPut: $(.
	args printOn: aStream delimiter: ', '.
	aStream nextPut: $).
]
