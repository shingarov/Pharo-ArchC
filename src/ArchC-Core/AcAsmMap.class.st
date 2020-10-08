Class {
	#name : #AcAsmMap,
	#superclass : #Object,
	#instVars : [
		'name',
		'forwardMap',
		'backMap'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmMap class >> from: collectionOfLines [
	^self new initializeFrom: collectionOfLines
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

{ #category : #initialization }
AcAsmMap >> initializeFrom: collectionOfLines [
	"For disassembly purposes, select the most specific symbolic names
	in a map.  For example, on SPARC, GPR %o1 is also called %r9.
	Of course, we can't know the intended symbolic form, but we at least
	attempt to say that %o1 is kind of more descriptive than %r9.
	
	This method works at the level of one map.  Assocs is a collection
	in which 	each element came from parsing one line (aka one map body).
	Each body then gives a collection of one (Form 1) or many individual
	arrows, which do not exist at the syntactic level.  For example,
	9->'%r9' is an arrow of cardinality 32, 9->'o1' has cardinality 8,
	and 14->'%sp' has cardinality 1.
	
	Answer a Dictionary mapping ints to the symbols of least cardinality
	(e.g., 9->'o1'). "
	| cardinalities |
	cardinalities := Dictionary new.
	forwardMap := Dictionary new.
	backMap := Dictionary new.
	collectionOfLines do: [ :aMapBody |
		aMapBody do: [ :entry |
			| existingCardinality cardinality int sym |
			cardinality := entry cardinality.
			int := entry value i.
			sym := entry sym.
			forwardMap at: sym put: int.
			existingCardinality := cardinalities at: int ifAbsent: [-1].
			existingCardinality == -1 ifTrue: [ "Brand new"
				cardinalities at: int put: cardinality.
				backMap at: int put: sym ]
			ifFalse: [ "Already exists, let's see if ours is better"
				existingCardinality > cardinality ifTrue: [
					cardinalities at: int put: cardinality.
					backMap at: int put: sym ] ] ] ].
	^self
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

{ #category : #printing }
AcAsmMap >> printOn: aStream [
	aStream nextPutAll: 'ac_asm_map '; nextPutAll: self name
]
