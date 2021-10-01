Class {
	#name : #AcAsmMapEntry,
	#superclass : #Object,
	#instVars : [
		'name',
		'value',
		'cardinality'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmMapEntry class >> name: name value: value [
	^ self new name: name value: value cardinality: 1
]

{ #category : #'instance creation' }
AcAsmMapEntry class >> name: name value: value cardinality: cardinality [
	^ self new name: name value: value cardinality: cardinality
]

{ #category : #converting }
AcAsmMapEntry >> aString [
	^ name
]

{ #category : #accessing }
AcAsmMapEntry >> cardinality [
	^ cardinality
]

{ #category : #accessing }
AcAsmMapEntry >> key [
	"For compatibility with association"
	^ name
]

{ #category : #accessing }
AcAsmMapEntry >> name [
	^ name
]

{ #category : #initialization }
AcAsmMapEntry >> name:nameArg value:valueArg cardinality: cardinalityArg [
	self assert: nameArg isString.
	self assert: valueArg isInteger.
	self assert: cardinalityArg isInteger. 

	name := nameArg.
	value := valueArg.
	cardinality := cardinalityArg
]

{ #category : #printing }
AcAsmMapEntry >> printOn: aStream [
	aStream nextPutAll: self name.
]

{ #category : #converting }
AcAsmMapEntry >> toBitVector: xlen [
	^ value toBitVector: xlen
]

{ #category : #converting }
AcAsmMapEntry >> toInt [
	^ value toInt
]

{ #category : #accessing }
AcAsmMapEntry >> value [
	^ value
]

{ #category : #accessing }
AcAsmMapEntry >> value: anInteger [
	self shouldNotImplement
]
