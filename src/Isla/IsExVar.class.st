Class {
	#name : #IsExVar,
	#superclass : #IsEx,
	#instVars : [
		'segments'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
IsExVar class >> segments: ss [ 
	^self basicNew segments: ss; yourself 
]

{ #category : #printing }
IsExVar >> printOn: aStream [
	segments
		do: [:seg | aStream nextPutAll: seg]
		separatedBy: [aStream nextPut: $.]
]

{ #category : #accessing }
IsExVar >> segments [
	^ segments
]

{ #category : #accessing }
IsExVar >> segments: anObject [
	segments := anObject
]
