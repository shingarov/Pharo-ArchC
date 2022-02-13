Class {
	#name : #'I_undefined',
	#superclass : #JibStatement,
	#category : #Isla
}

{ #category : #printing }
I_undefined >> printOn: aStream [
	aStream nextPutAll: 'arbitrary'
]
