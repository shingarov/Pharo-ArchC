"
Tests for Dictionary extensions in ArchC package.
"
Class {
	#name : #AssociationArchCExtTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #tests }
AssociationArchCExtTest >> testComma [
	"Two associations separated by a comma will form a dictionary.
	This is useful for uniformity with three- and more-associations case."
	| d |
	d := ('zero' -> 0), ('one' -> 1).
	self assert: (d at: 'zero') equals: 0.
	self assert: (d at: 'one') equals: 1.
	self should: [d at: 'two'] raise: KeyNotFound 
]

{ #category : #tests }
AssociationArchCExtTest >> testDictionaryFrom2Assocs [
	"Two associations separated by a comma will form a dictionary.
	This is useful for uniformity with three- and more-associations case."
	| d |
	d := ('a' -> 1), ('b' -> 2).
	self assert: (d at: 'a') equals: 1.
	self assert: (d at: 'b') equals: 2.
	self should: [d at: 'c'] raise: KeyNotFound 
]
