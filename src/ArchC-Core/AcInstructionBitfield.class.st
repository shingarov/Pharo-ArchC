Class {
	#name : #AcInstructionBitfield,
	#superclass : #Object,
	#instVars : [
		'name',
		'width',
		'signed'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcInstructionBitfield class >> name:nameArg width:widthArg signed:signedArg [
	^ self new name:nameArg width:widthArg signed:signedArg
]

{ #category : #accessing }
AcInstructionBitfield >> bitWidth [
	"Return the width of this field in bits"
	^ width
]

{ #category : #testing }
AcInstructionBitfield >> isFixedValue [
	"Return true, if the value of this field is fixed,
	 that is, it has the same value for all instructions.

	 Q: which ISAs define formats with fixed-value bitfields?
	"
	^ name isInteger
]

{ #category : #'accessing - compatibility' }
AcInstructionBitfield >> key [
	^ name
]

{ #category : #accessing }
AcInstructionBitfield >> name [
	^ name
]

{ #category : #accessing }
AcInstructionBitfield >> name:nameArg width:widthArg signed:signedArg [
	name := nameArg.
	width := widthArg.
	signed := signedArg.
]

{ #category : #'printing & storing' }
AcInstructionBitfield >> printOn:aStream [
	name isString ifTrue: [
		aStream nextPutAll: name.
	] ifFalse: [ 
		self assert: name isInteger.
		name printOn: aStream.
	].
	aStream nextPut: $:.
	width printOn: aStream.
	signed ifTrue: [
		aStream nextPutAll: ':s'
	].
]

{ #category : #'accessing - compatibility' }
AcInstructionBitfield >> value [
	^ signed ifTrue: [ width negated ] ifFalse: [ width ]
]
