Class {
	#name : #SemanticTerm,
	#superclass : #Object,
	#instVars : [
		'functor',
		'args'
	],
	#category : #'ArchC-Core'
}

{ #category : #logic }
SemanticTerm >> addOperandNumbersTo: aSet [ 
	args do: [ :arg | arg addOperandNumbersTo: aSet ].
	^aSet
]

{ #category : #accessing }
SemanticTerm >> args [
	^ args
]

{ #category : #accessing }
SemanticTerm >> args: anObject [
	args := anObject
]

{ #category : #accessing }
SemanticTerm >> functor [
	^ functor
]

{ #category : #accessing }
SemanticTerm >> functor: anObject [
	functor := anObject
]

{ #category : #logic }
SemanticTerm >> printConditionsOn: aStream instruction: instruction [
	args do: [ :arg | arg printConditionsOn: aStream instruction: instruction ].

]

{ #category : #logic }
SemanticTerm >> printRewriteHeadOn: aStream [
	aStream nextPutAll: functor; nextPut: $(.
	args printUsing: #printRewriteHeadOn: on: aStream.
	aStream nextPut: $).
]
