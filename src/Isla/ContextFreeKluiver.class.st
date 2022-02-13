Class {
	#name : #ContextFreeKluiver,
	#superclass : #Object,
	#instVars : [
		'paragraphs'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
ContextFreeKluiver class >> paragraphs: ps [ 
	^self basicNew 
		paragraphs: ps;
		yourself 
]

{ #category : #compilation }
ContextFreeKluiver >> kluiver [
	"Perform context-sensitive analysis and answer the final Isla program."
	| k |
	k := Kluiver new.
	paragraphs do: [ :p | p analyzeContextFor: k ].
	^k
]

{ #category : #accessing }
ContextFreeKluiver >> paragraphs [
	^ paragraphs
]

{ #category : #accessing }
ContextFreeKluiver >> paragraphs: ps [
	paragraphs := ps.
	ps do: [ :p | p program: self ]
]
