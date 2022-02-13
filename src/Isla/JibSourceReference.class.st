Class {
	#name : #JibSourceReference,
	#superclass : #Object,
	#instVars : [
		'statement',
		'fileIndex',
		'from',
		'to'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
JibSourceReference class >> fileIndex: f from: from to: to [
	^self basicNew fileIndex: f; from: from; to: to; yourself
]

{ #category : #accessing }
JibSourceReference >> fileIndex [
	^ fileIndex
]

{ #category : #accessing }
JibSourceReference >> fileIndex: anObject [
	fileIndex := anObject
]

{ #category : #accessing }
JibSourceReference >> fileReference [
	^ self program sourceFiles at: fileIndex+1
]

{ #category : #accessing }
JibSourceReference >> from [
	^ from
]

{ #category : #accessing }
JibSourceReference >> from: anObject [
	from := anObject
]

{ #category : #accessing }
JibSourceReference >> program [ 
	^statement program
]

{ #category : #accessing }
JibSourceReference >> sourceInterval [ 
	self text isNil ifTrue: [ ^nil ].
	^ (self text charPositionOf: from)
		to: (self text charPositionOf: to)
]

{ #category : #accessing }
JibSourceReference >> statement [
	^ statement
]

{ #category : #accessing }
JibSourceReference >> statement: anObject [
	statement := anObject
]

{ #category : #accessing }
JibSourceReference >> text [
	^self fileReference
		ifNil: [ nil ]
		ifNotNil: [ :f| f readStream contents ]
]

{ #category : #accessing }
JibSourceReference >> to [
	^ to
]

{ #category : #accessing }
JibSourceReference >> to: anObject [
	to := anObject
]
