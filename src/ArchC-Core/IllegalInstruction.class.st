Class {
	#name : #IllegalInstruction,
	#superclass : #Error,
	#instVars : [
		'encoding'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
IllegalInstruction class >> encoding: aBinary [
	^self basicNew encoding: aBinary; yourself
]

{ #category : #signalling }
IllegalInstruction class >> signalWith: aBinaryEncoding [
	^(self encoding: aBinaryEncoding) signal
]

{ #category : #accessing }
IllegalInstruction >> encoding [
	^ encoding
]

{ #category : #accessing }
IllegalInstruction >> encoding: anObject [
	encoding := anObject
]

{ #category : #private }
IllegalInstruction >> isResumable [
	^true
]
