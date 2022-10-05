Class {
	#name : #BitVectorEmpty,
	#superclass : #BitVector,
	#category : #BitVector
}

{ #category : #slicing }
BitVectorEmpty >> , another [
	^ another
]

{ #category : #comparing }
BitVectorEmpty >> = another [
	^ self == another
]

{ #category : #'operations - bitwise' }
BitVectorEmpty >> bitShiftLeft: amount [
	amount == 0 ifTrue:[ ^ self ].
	self error: 'Shifting empty is not and should not be supported'
]

{ #category : #'operations - bitwise' }
BitVectorEmpty >> bitShiftRightArithmetic: amount [
	amount == 0 ifTrue:[ ^ self ].
	self error: 'Shifting empty is not and should not be supported'
]

{ #category : #operations }
BitVectorEmpty >> copyFrom: hiBit to: loBit [
	self error: 'Extracting parts of an empty bit vector is not supported'
]

{ #category : #comparing }
BitVectorEmpty >> hash [
	"superclass BitVector says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #operations }
BitVectorEmpty >> inEnvironment: aDictionary [
	^ self
]

{ #category : #accessing }
BitVectorEmpty >> length [
	^ 0
]
