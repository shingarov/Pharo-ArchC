Class {
	#name : #IsExIs,
	#superclass : #IsEx,
	#instVars : [
		'l',
		'r'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
IsExIs class >> l: aVarSegment r: anId [
	^self basicNew l: aVarSegment; r: anId; yourself 
]

{ #category : #accessing }
IsExIs >> l [
	^ l
]

{ #category : #accessing }
IsExIs >> l: anObject [
	l := anObject
]

{ #category : #printing }
IsExIs >> printOn: aStream [
	l printOn: aStream.
	aStream nextPutAll: ' ≡ '.
	aStream nextPutAll: r.
]

{ #category : #accessing }
IsExIs >> r [
	^ r
]

{ #category : #accessing }
IsExIs >> r: anObject [
	r := anObject
]
