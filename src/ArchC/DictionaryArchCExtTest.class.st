"
Tests for Dictionary extensions in ArchC package.
"
Class {
	#name : #DictionaryArchCExtTest,
	#superclass : #TestCase,
	#category : #'ArchC-Tests-Ext'
}

{ #category : #'tests - dictionary assocition access' }
DictionaryArchCExtTest >> testDictionaryFromAssocSequence [
	| d |
	d := ('a' -> 1), ('b' -> 2), ('c' -> 3).
	self assert: (d at: 'a') equals: 1.
	self assert: (d at: 'b') equals: 2.
	self assert: (d at: 'c') equals: 3.
	self should: [d at: 'x'] raise: KeyNotFound 
]

{ #category : #'tests - dictionary assocition access' }
DictionaryArchCExtTest >> testDictionaryFromAssocs [
	| a d |
	a := Array with: 'a' -> 1 with: 'b' -> 2.
	d := Dictionary newFromAssociations: a.
	self assert: (d at: 'a') equals: 1.
	self assert: (d at: 'b') equals: 2.
	self should: [d at: 'c'] raise: KeyNotFound 
]
