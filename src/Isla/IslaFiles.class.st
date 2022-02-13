Class {
	#name : #IslaFiles,
	#superclass : #IslaParagraph,
	#instVars : [
		'files'
	],
	#category : #Isla
}

{ #category : #'as yet unclassified' }
IslaFiles class >> files: ff [ 
	^ self basicNew files: ff; yourself
]

{ #category : #'as yet unclassified' }
IslaFiles >> analyzeContextFor: aKluiver [
	aKluiver sourceFiles: (
		files collect: [ :f |
			f isEmpty
				ifTrue: [ nil ]
				ifFalse: [ FileSystem / f ]]
		)
]

{ #category : #accessing }
IslaFiles >> files [
	^ files
]

{ #category : #accessing }
IslaFiles >> files: anObject [
	files := anObject
]
