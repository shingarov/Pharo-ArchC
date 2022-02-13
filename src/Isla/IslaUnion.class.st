Class {
	#name : #IslaUnion,
	#superclass : #IslaNamedCollectionParagraph,
	#category : #Isla
}

{ #category : #grammar }
IslaUnion class >> keyword [
	^'union'
]

{ #category : #'as yet unclassified' }
IslaUnion >> analyzeContextFor: aKluiver [ 
	aKluiver unions at: name put: self
]

{ #category : #printing }
IslaUnion >> printOn: aStream [
	aStream nextPutAll: '%union '.
	aStream nextPutAll: name
]
