Class {
	#name : #'CDEF_let',
	#superclass : #IslaNamedCollectionParagraph,
	#instVars : [
		'type'
	],
	#category : #Isla
}

{ #category : #compilation }
CDEF_let >> analyzeContextFor: aKluiver [ 
	aKluiver lets at: name put: self.
	program := aKluiver 
]

{ #category : #printing }
CDEF_let >> printOn: aStream [
	aStream nextPutAll: 'let '.
	aStream nextPutAll: name.
	aStream nextPutAll: ' ∈ '.
	type printOn: aStream
]

{ #category : #accessing }
CDEF_let >> type [
	^ type
]

{ #category : #accessing }
CDEF_let >> type: anObject [
	type := anObject
]
