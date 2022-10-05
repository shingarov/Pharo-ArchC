Class {
	#name : #BitVectorSymbolic,
	#superclass : #BitVector,
	#instVars : [
		'symbol',
		'length'
	],
	#category : #BitVector
}

{ #category : #comparing }
BitVectorSymbolic >> = another [
	self class ~~ another class ifTrue: [ 
		^ self = (another toBitVector: length)   
	].
	length ~~ another length ifTrue: [ 
		^ false.
	].
	symbol ~= another symbol ifTrue:[
		^ false
	].
	^ true
]

{ #category : #'operations - bitwise' }
BitVectorSymbolic >> bitAnd: another [
	self assert: length = another length.
	self assert: another isConcrete.
	another = 0 ifTrue: [ 
		^ another
	] ifFalse: [ 
		self error: 'Bit-and of symbolic bit vector with non-zero vector is not supported'
	].
]

{ #category : #'operations - bitwise' }
BitVectorSymbolic >> bitShiftLeft: amount [
   amount == 0 ifTrue:[ ^ self ].
   self error: 'Shifting symbolic bit vectors is not supported'
]

{ #category : #'operations - bitwise' }
BitVectorSymbolic >> bitShiftRightArithmetic: amount [
   amount == 0 ifTrue:[ ^ self ].
   self error: 'Shifting symbolic bit vectors is not supported'
]

{ #category : #operations }
BitVectorSymbolic >> copyFrom: hiBit to: loBit [
	(loBit == 0 and: [hiBit == (length - 1)]) ifTrue: [ 
		^ self
	].
	self error: 'Extracting parts of a symbolic bit vector is not supported'
]

{ #category : #comparing }
BitVectorSymbolic >> hash [
	^ symbol hash bitXor: length hash
]

{ #category : #operations }
BitVectorSymbolic >> inEnvironment: aDictionary [
	(aDictionary includesKey: symbol) ifTrue: [ 
		^ (aDictionary at: symbol) toBitVector: length
	].
	^ self
]

{ #category : #initialization }
BitVectorSymbolic >> initializeWithLength: len symbol: sym [
	self assert: len < 63.

	length := len.
	symbol := sym
]

{ #category : #accessing }
BitVectorSymbolic >> length [
	^ length
]

{ #category : #'printing & storing' }
BitVectorSymbolic >> printOn:aStream [
	aStream nextPutAll: 'BV'.    
	self length printOn: aStream.    
	aStream nextPut: $:; 
			nextPutAll: symbol
]

{ #category : #accessing }
BitVectorSymbolic >> sym [
	^ symbol
]

{ #category : #accessing }
BitVectorSymbolic >> symbol [
	^ symbol
]
