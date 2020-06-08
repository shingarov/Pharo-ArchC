"
I am a dynamically-scoped variable, similar to Lisp's ""special variables""
(those earmuffed things)
"
Class {
	#name : #SpecialVariable,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'ArchC-Opal'
}

{ #category : #'instance creation' }
SpecialVariable class >> name: aString [
	^self basicNew 
		name: aString;
		yourself
]

{ #category : #'instance creation' }
SpecialVariable class >> new [
	self error: 'Please use #name:'
]

{ #category : #coercing }
SpecialVariable >> asBitVector: anInteger [ 
	^self name asString asBitVector: anInteger 
]

{ #category : #accessing }
SpecialVariable >> name [
	^ name
]

{ #category : #accessing }
SpecialVariable >> name: anObject [
	name := anObject
]
