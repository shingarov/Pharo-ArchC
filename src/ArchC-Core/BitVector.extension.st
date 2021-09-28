Extension { #name : #BitVector }

{ #category : #'*ArchC-Core' }
BitVector >> asBEByteArray [
	self isSymbolic ifTrue: [ MustBeConcrete signal ].
	"length of 0 is covered in EmptyBitVector".
	self length == 32 ifFalse: [ self shouldBeImplemented ].
	^ByteArray
		with: (self copyFrom: 31 to: 24) value
		with: (self copyFrom: 23 to: 16) value
		with: (self copyFrom: 15 to: 8)  value
		with: (self copyFrom: 7 to: 0) value
]

{ #category : #'*ArchC-Core' }
BitVector >> asLEByteArray [
	self isSymbolic ifTrue: [ MustBeConcrete signal ].
	"length of 0 is covered in EmptyBitVector".
	self length == 32 ifFalse: [ self shouldBeImplemented ].
	^ByteArray
		with: (self copyFrom: 7 to: 0) value
		with: (self copyFrom: 15 to: 8)  value
		with: (self copyFrom: 23 to: 16) value
		with: (self copyFrom: 31 to: 24) value
]

{ #category : #'*ArchC-Core' }
BitVector >> decodeFor: anISA [
	^anISA decodeInt: self
]
