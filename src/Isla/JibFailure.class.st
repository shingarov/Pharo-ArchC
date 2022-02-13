Class {
	#name : #JibFailure,
	#superclass : #JibStatement,
	#category : #Isla
}

{ #category : #printing }
JibFailure >> printOn: aStream [
	aStream nextPutAll: 'failure'
]
