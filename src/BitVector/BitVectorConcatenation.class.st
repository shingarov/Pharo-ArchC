Class {
	#name : #BitVectorConcatenation,
	#superclass : #BitVector,
	#instVars : [
		'slices'
	],
	#category : #BitVector
}

{ #category : #slicing }
BitVectorConcatenation >> , another [
	another length == 0 ifTrue: [ 
		^ self
	].
	another isConcatenation ifTrue: [ 
		^ BitVector concatAll: slices , another slices
	].
	^ BitVector concatAll: (slices copyWith: another)
]

{ #category : #comparing }
BitVectorConcatenation >> = another [
	self class ~~ another class ifTrue: [ 
		^ false.
	].
	slices size ~~ another slices size ifTrue: [ 
		^ false.
	].
	slices with: another slices do: [:s1 :s2 |  
		s1 = s2 ifFalse: [ ^ false ]
	].
	^ true
]

{ #category : #'operations - bitwise' }
BitVectorConcatenation >> bitAnd: another [
	| andedSlices sliceLo |

	self assert: self length = another length.

	andedSlices := Array new: slices size.
	sliceLo := 0.
	slices size downTo: 1 do: [:sliceI | 
		| slice sliceHi andedSlice |

		slice := slices at: sliceI.
		sliceHi := sliceLo + slice length - 1.

		andedSlice := slice bitAnd: (another copyFrom: sliceHi to: sliceLo).
		andedSlices at: sliceI put: andedSlice.
		sliceLo := sliceHi + 1.
	].
	^ BitVector concatAll: andedSlices.
]

{ #category : #'operations - bitwise' }
BitVectorConcatenation >> bitShiftLeft: amount [
	amount == 0 ifTrue:[ ^ self ].
	self error: 'Shifting concatenated bitvectors is not supported'
]

{ #category : #'operations - bitwise' }
BitVectorConcatenation >> bitShiftRightArithmetic: amount [
	amount == 0 ifTrue:[ ^ self ].
	self error: 'Shifting concatenated bitvectors is not supported'
]

{ #category : #operations }
BitVectorConcatenation >> copyFrom: hiBit to: loBit [
	| sliceLoBit |

	self assert: hiBit < self length.
	self assert: loBit >= 0.
	self assert: hiBit >= loBit.     

	sliceLoBit := 0.
	slices reverseDo: [ :slice |
		| sliceHiBit |

		sliceHiBit := sliceLoBit + slice length - 1.
		(sliceLoBit <= loBit and: [ sliceHiBit >= hiBit ]) ifTrue: [ 
			^ slice copyFrom: hiBit - sliceLoBit to: loBit - sliceLoBit.
		] ifFalse: [ 
			sliceLoBit := sliceHiBit + 1.
		].
	].
]

{ #category : #comparing }
BitVectorConcatenation >> hash [
	| hash |

	hash := 0.
	slices do: [:e | hash := hash bitXor: e hash ].
	^ hash
]

{ #category : #operations }
BitVectorConcatenation >> inEnvironment: aDictionary [
	^ (BitVector concatAll: (slices collect: [ :slice | slice inEnvironment: aDictionary ])) simplify
]

{ #category : #initialization }
BitVectorConcatenation >> initializeWithSlices: slicesArg [
	slices := slicesArg
]

{ #category : #testing }
BitVectorConcatenation >> isConcatenation [
	^ true
]

{ #category : #testing }
BitVectorConcatenation >> isLeaf [
	^ false
]

{ #category : #accessing }
BitVectorConcatenation >> length [
	^ slices sum: [ :slice | slice length ]
]

{ #category : #'accessing-private' }
BitVectorConcatenation >> slices [
	^ slices
]
