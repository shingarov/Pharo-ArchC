Class {
	#name : #IslaReferenceCell,
	#superclass : #Object,
	#instVars : [
		'sort',
		'id'
	],
	#category : #Isla
}

{ #category : #sorting }
IslaReferenceCell class >> sort: s id: id [ 
	^self basicNew 
		sort: s; id: id;
		yourself 
]

{ #category : #compilation }
IslaReferenceCell >> analyzeContextFor: aKluiver [ 
	^aKluiver resolve: sort named: id
]

{ #category : #accessing }
IslaReferenceCell >> id [
	^ id
]

{ #category : #accessing }
IslaReferenceCell >> id: anObject [
	id := anObject
]

{ #category : #accessing }
IslaReferenceCell >> sort [
	^ sort
]

{ #category : #accessing }
IslaReferenceCell >> sort: anObject [
	sort := anObject
]
