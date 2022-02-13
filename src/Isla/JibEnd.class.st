Class {
	#name : #JibEnd,
	#superclass : #JibStatement,
	#category : #Isla
}

{ #category : #printing }
JibEnd >> printOn: aStream [
	aStream nextPutAll: 'end'
]
