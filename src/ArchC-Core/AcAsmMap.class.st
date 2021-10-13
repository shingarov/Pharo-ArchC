Class {
	#name : #AcAsmMap,
	#superclass : #Object,
	#instVars : [
		'name',
		'entries',
		'forwardMap',
		'backMap'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmMap class >> name: aString entries: aCollection [
	^ self new name: aString entries: aCollection
]

{ #category : #API }
AcAsmMap >> backLookup: int [
	^backMap at: int 
]

{ #category : #accessing }
AcAsmMap >> backMap [
	^ backMap
]

{ #category : #accessing }
AcAsmMap >> backMap: anObject [
	backMap := anObject
]

{ #category : #accessing }
AcAsmMap >> forwardMap [
	^ forwardMap
]

{ #category : #accessing }
AcAsmMap >> forwardMap: anObject [
	forwardMap := anObject
]

{ #category : #API }
AcAsmMap >> lookup: symbol [
	^forwardMap at: symbol 
]

{ #category : #accessing }
AcAsmMap >> name [
	^ name
]

{ #category : #helpers }
AcAsmMap >> name2self [
	^self name -> self
]

{ #category : #accessing }
AcAsmMap >> name: anObject [
	name := anObject
]

{ #category : #initialization }
AcAsmMap >> name: nameArg entries: entriesArg [
	"For disassembly purposes, select the most specific symbolic names
	in a map.  For example, on SPARC, GPR %o1 is also called %r9.
	Of course, we can't know the intended symbolic form, but we at least
	attempt to say that %o1 is kind of more descriptive than %r9.
	
	This method works at the level of one map.  Assocs is a collection
	in which    each element came from parsing one line (aka one map body).
	Each body then gives a collection of one (Form 1) or many individual
	arrows, which do not exist at the syntactic level.  For example,
	9->'%r9' is an arrow of cardinality 32, 9->'o1' has cardinality 8,
	and 14->'%sp' has cardinality 1.
	
	Answer a Dictionary mapping ints to the symbols of least cardinality
	(e.g., 9->'o1'). "
	| cardinalities |

	name := nameArg.
	entries := entriesArg.

	cardinalities := Dictionary new.
	forwardMap := Dictionary new.
	backMap := Dictionary new.
	entries do: [ :entry |
			| existingCardinality entryCardinality entryValue entryName |
			entryCardinality := entry cardinality.
			entryValue := entry value.
			entryName := entry name.
			forwardMap at: entryName put: entry.
			existingCardinality := cardinalities at: entryValue ifAbsent: [-1].
			existingCardinality == -1 ifTrue: [ "Brand new"
				cardinalities at: entryValue put: entryCardinality.
				backMap at: entryValue put: entry ]
			ifFalse: [ "Already exists, let's see if ours is better"
				existingCardinality > entryCardinality ifTrue: [
					cardinalities at: entryValue put: entryCardinality.
					backMap at: entryValue put: entry ] ] ] .
	^self
]

{ #category : #printing }
AcAsmMap >> printOn: aStream [
	aStream nextPutAll: 'ac_asm_map '; nextPutAll: self name
]
