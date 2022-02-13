Class {
	#name : #JibSSA,
	#superclass : #JibStatement,
	#instVars : [
		'name',
		'expression'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
JibSSA class >> name: v expression: e [ 
	^self basicNew name: v; expression: e ; yourself 
]

{ #category : #accessing }
JibSSA >> expression [
	^ expression
]

{ #category : #accessing }
JibSSA >> expression: anObject [
	expression := anObject
]

{ #category : #accessing }
JibSSA >> name [
	^ name
]

{ #category : #accessing }
JibSSA >> name: anObject [
	name := anObject
]

{ #category : #printing }
JibSSA >> printOn: aStream [
	name printOn: aStream.
	aStream nextPutAll: ' = '.
	expression printOn: aStream 
]
