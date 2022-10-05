Class {
	#name : #BitVectorConcrete,
	#superclass : #BitVector,
	#instVars : [
		'value',
		'length'
	],
	#category : #BitVector
}

{ #category : #operations }
BitVectorConcrete >> , another [
	self assert: another isBitVector.
	another isConcrete ifTrue: [ 
		^ ((value << another length) | another value)
			toBitVector: length + another length
	].
	^ super , another

	"
	(2r101 toBitVector: 3) , (2r010 toBitVector: 3)
	"
]

{ #category : #comparing }
BitVectorConcrete >> = another [
	self class ~~ another class ifTrue: [ 
		^ self = (another toBitVector: length)
	].
	length ~~ another length ifTrue: [ 
		^ false.
	].
	value ~~ another value ifTrue:[
		^ false
	].
	^ true
]

{ #category : #'operations - bitwise' }
BitVectorConcrete >> bitAnd: another [
	self assert: length = another length.
	^ BitVector value: (value bitAnd: another value) length: length
]

{ #category : #'operations - bitwise' }
BitVectorConcrete >> bitShiftLeft: amount [
	^ (value bitShift: amount) toBitVector: length

	"
	(2r0111 toBitVector: 4) bitShiftLeft: 2
	(2r1111 toBitVector: 4) bitShiftLeft: 2
	(2r0101 toBitVector: 4) bitShiftLeft: 1
	(2r1101 toBitVector: 4) bitShiftLeft: 1
	"
]

{ #category : #'operations - bitwise' }
BitVectorConcrete >> bitShiftRightArithmetic: amount [
	| shiftedBits signBits |

	amount == 0 ifTrue:[ ^ self ].

	shiftedBits := value bitShift: amount negated.
	(self bitTest: (1 bitShift: length - 1)) ifTrue: [ 
		"Negative value"
		signBits := ((1 bitShift: amount) - 1) bitShift: length - amount.
	] ifFalse: [ 
		signBits := 0.
	].
	^ (shiftedBits bitOr: signBits) toBitVector: length.

	"
	(2r0111 toBitVector: 4) bitShiftRightArithmetic: 2
	(2r1111 toBitVector: 4) bitShiftRightArithmetic: 2
	(2r0101 toBitVector: 4) bitShiftRightArithmetic: 1
	(2r1101 toBitVector: 4) bitShiftRightArithmetic: 1
	"
]

{ #category : #'operations - bitwise' }
BitVectorConcrete >> bitTest: mask [
	^ (value bitAnd: mask value) ~~ 0
]

{ #category : #operations }
BitVectorConcrete >> copyFrom: hiBit to: loBit [
	| extractedValue extractedLength |

	self assert: hiBit < length.
	self assert: loBit >= 0.
	self assert: hiBit >= loBit.

	(loBit == 0 and: [ hiBit == length ]) ifTrue: [ 
		^ self
	].
	extractedLength := hiBit - loBit + 1.
	extractedValue := (value bitShift: loBit negated) bitAnd: ((1 bitShift: extractedLength) - 1).
	^ extractedValue toBitVector: extractedLength
]

{ #category : #comparing }
BitVectorConcrete >> hash [
	^ value hash bitXor: length hash
]

{ #category : #operations }
BitVectorConcrete >> inEnvironment: aDictionary [
	^ self
]

{ #category : #initialization }
BitVectorConcrete >> initializeWithLength: len value: val [
	self assert: len < 63.
	self assert: val isInteger.
	"self assert: (val between: 0 and: 1 << len)."

	length := len.
	value := val bitAnd: (1 bitShift: length) - 1
]

{ #category : #testing }
BitVectorConcrete >> isConcrete [
	^ true
]

{ #category : #accessing }
BitVectorConcrete >> length [
	^ length
]

{ #category : #'printing & storing' }
BitVectorConcrete >> printOn:aStream [
	super printOn: aStream.
	aStream nextPut: $:.
	(length \\ 8) == 0 ifTrue: [ 
		aStream nextPutAll:'#x'.
		value printOn:aStream base:16 size:length // 8 fill:$0 
	] ifFalse: [ 
		aStream nextPutAll:'#b'.
		value printOn:aStream base:2 size:length fill:$0 
	].
]

{ #category : #accessing }
BitVectorConcrete >> signedValue [
	(self bitTest: (1 bitShift: length - 1)) ifTrue: [ 
		^ value - (1 bitShift: length)
	].
	^ value

	"
	(2r0111 toBitVector: 4) signedValue
	(2r1111 toBitVector: 4) signedValue
	"
]

{ #category : #accessing }
BitVectorConcrete >> value [
	^ value
]
