Class {
	#name : #BitVector,
	#superclass : #Object,
	#classVars : [
		'Empty'
	],
	#category : #BitVector
}

{ #category : #'instance creation' }
BitVector class >> concatAll: slices [
	| simplified  prevSlice prevSliceIndex  |

	self assert: (slices allSatisfy: [:e | e isBitVector ]).

	simplified := Array new: slices size.
	prevSlice := slices first.
	simplified at: 1 put: prevSlice.
	prevSliceIndex := 1.
	2 to: slices size do: [:currSliceIndex | 
		| currSlice |

		currSlice := slices at: currSliceIndex.
		(slices at: currSliceIndex) ~~ currSlice ifTrue: [ 

		].
		(prevSlice isConcrete and:[ currSlice isConcrete]) ifTrue: [ 
			prevSlice := prevSlice , currSlice.

		] ifFalse: [ 
			prevSlice := currSlice.
			prevSliceIndex := prevSliceIndex + 1.
		].
		simplified at: prevSliceIndex put: prevSlice.
	].
	prevSliceIndex == 1 ifTrue: [ 
		^ prevSlice.
	].
	^ BitVectorConcatenation basicNew initializeWithSlices: (simplified copyFrom: 1 to: prevSliceIndex)

	"
	BitVector concatAll: { (2r101 toBitVector: 3) . (2r010 toBitVector: 3) . (2r111 toBitVector: 3) }
	BitVector concatAll: { (2r101 toBitVector: 3) . ('x' toBitVector: 3) . (2r111 toBitVector: 3) }
	BitVector concatAll: { ('y' toBitVector: 3) . (2r010 toBitVector: 3) . (2r111 toBitVector: 3) }
	(BitVector concatAll: { (2r101 toBitVector: 3) . ('x' toBitVector: 3) . (2r111 toBitVector: 3) }) simplify

	"
]

{ #category : #'instance creation' }
BitVector class >> empty [
	^ Empty
]

{ #category : #initialization }
BitVector class >> initialize [
	Empty := BitVectorEmpty new
]

{ #category : #'instance creation' }
BitVector class >> sym: sym length: length [
	^ BitVectorSymbolic basicNew initializeWithLength: length symbol: sym
]

{ #category : #'instance creation' }
BitVector class >> value: value length: length [ 
	^ BitVectorConcrete basicNew initializeWithLength: length value: value
]

{ #category : #operations }
BitVector >> , another [
	another length == 0 ifTrue: [ ^ self ].
	^ BitVector concatAll: (Array with: self with: another)
]

{ #category : #'operations - bitwise' }
BitVector >> << amount [
	^ self bitShiftLeft: amount
]

{ #category : #comparing }
BitVector >> = another [
	^ self subclassResponsibility
]

{ #category : #'operations - bitwise' }
BitVector >> bitAnd: another [
	self subclassResponsibility
]

{ #category : #'operations - bitwise' }
BitVector >> bitShiftLeft: amount [
	^ self subclassResponsibility
]

{ #category : #'operations - bitwise' }
BitVector >> bitShiftRightArithmetic: amount [
	self subclassResponsibility
]

{ #category : #operations }
BitVector >> copyFrom: hiBit to: loBit [
	^ self subclassResponsibility

]

{ #category : #comparing }
BitVector >> hash [
	^ self subclassResponsibility
]

{ #category : #operations }
BitVector >> inEnvironment: aDictionary [
	self subclassResponsibility
]

{ #category : #testing }
BitVector >> isBitVector [
	^ true
]

{ #category : #testing }
BitVector >> isConcatenation [
	^ false
]

{ #category : #testing }
BitVector >> isConcrete [
	^ false
]

{ #category : #testing }
BitVector >> isLeaf [
	^ true
]

{ #category : #testing }
BitVector >> isSymbolic [
	^ self isConcrete not
]

{ #category : #accessing }
BitVector >> length [
	^ self subclassResponsibility
]

{ #category : #'printing & storing' }
BitVector >> printOn:aStream [
	aStream nextPutAll: 'BV'.
	self length printOn: aStream
]

{ #category : #operations }
BitVector >> simplify [
	"Return self since this BitVector are always kept simplified
	 (as opposed to Z3-based BitVectors)"
	^ self
]

{ #category : #operations }
BitVector >> subrange: interval [
	^ self copyFrom: interval first to: interval last
]

{ #category : #conversion }
BitVector >> toBitVector: xlen [
	self assert: self length = xlen.
	^ self.
]
