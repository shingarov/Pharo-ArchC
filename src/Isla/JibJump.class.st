Class {
	#name : #JibJump,
	#superclass : #JibGoto,
	#instVars : [
		'condition'
	],
	#category : #Isla
}

{ #category : #accessing }
JibJump >> condition [
	^ condition
]

{ #category : #accessing }
JibJump >> condition: anObject [
	condition := anObject
]

{ #category : #printing }
JibJump >> printOn: aStream [
	aStream nextPutAll: 'if '.
	condition printOn: aStream.
	aStream nextPutAll: ' goto '.
	to printOn: aStream
]
