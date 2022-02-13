Class {
	#name : #JibGoto,
	#superclass : #JibStatement,
	#instVars : [
		'to'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
JibGoto class >> to: target [ 
	^self basicNew to: target; yourself
]

{ #category : #printing }
JibGoto >> printOn: aStream [
	aStream nextPutAll: 'goto '.
	to printOn: aStream
]

{ #category : #accessing }
JibGoto >> to [
	^ to
]

{ #category : #accessing }
JibGoto >> to: anObject [
	to := anObject
]
