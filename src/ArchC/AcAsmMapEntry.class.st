Class {
	#name : #AcAsmMapEntry,
	#superclass : #Object,
	#instVars : [
		'i',
		'sym',
		'cardinality'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
AcAsmMapEntry class >> i: i sym: sym cardinality: c [
	^self new
		i: i; sym: sym; cardinality: c;
		yourself
]

{ #category : #accessing }
AcAsmMapEntry >> cardinality [
	^ cardinality
]

{ #category : #accessing }
AcAsmMapEntry >> cardinality: anObject [
	cardinality := anObject
]

{ #category : #accessing }
AcAsmMapEntry >> i [
	^ i
]

{ #category : #accessing }
AcAsmMapEntry >> i: anObject [
	i := anObject
]

{ #category : #printing }
AcAsmMapEntry >> printOn: aStream [
	aStream nextPutAll: self sym; nextPutAll: '->'.
	self i printOn: aStream.
	aStream nextPutAll: '*'.
	self cardinality printOn: aStream.
]

{ #category : #accessing }
AcAsmMapEntry >> sym [
	^ sym
]

{ #category : #accessing }
AcAsmMapEntry >> sym: anObject [
	sym := anObject
]
