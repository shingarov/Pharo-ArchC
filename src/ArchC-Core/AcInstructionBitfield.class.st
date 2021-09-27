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

{ #category : #'accessing - compatibility' }
AcInstructionBitfield >> key [
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
	aStream nextPutAll: name.
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
