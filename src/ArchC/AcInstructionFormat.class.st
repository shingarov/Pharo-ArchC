"
An ISA defines several ""instruction formats"" consisting of a plurality of ""bit fields"".
Each processor instruction is encoded according to one of these formats.
For example, the ""ori ra, rs, #imm"" instruction in the PowerPC ISA is encoded according to the D4 format, which consists of 4 bit fields:
opcd:6,
rs:5,
ra:5,
ui:16.

"
Class {
	#name : #AcInstructionFormat,
	#superclass : #Object,
	#instVars : [
		'name',
		'bitFields'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instruction encoding' }
AcInstructionFormat >> binaryEncoding [
	"Answer the bit vector representing this format's binary encoding.
	Most bits in this vector will be variable, so the answer is an
	algebraic expression over field values."
	^self bitFields
		inject: (BitVector empty)
		into: [ :soFar :f | soFar, (f key toBitVector: f value abs) ]
]

{ #category : #accessing }
AcInstructionFormat >> bitFieldNames [
	"Answer a sequenceable collection of bit-field names (Strings),
	in MSB to LSB order."
	^ bitFields collect: [ :anAssociation | "each Association is FieldNameString -> width"
		anAssociation key ] 
]

{ #category : #accessing }
AcInstructionFormat >> bitFields [
	^ bitFields
]

{ #category : #accessing }
AcInstructionFormat >> bitFields: anObject [
	bitFields := anObject
]

{ #category : #accessing }
AcInstructionFormat >> isSigned: fieldName [
	"Answer whether the field is signed."
	self bitFields do: [ :assoc |
		assoc key = fieldName ifTrue: [ ^assoc value < 0 ]
	].
	KeyNotFound signalFor: fieldName
]

{ #category : #accessing }
AcInstructionFormat >> name [
	^ name
]

{ #category : #accessing }
AcInstructionFormat >> name: aString [
	name := aString
]

{ #category : #accessing }
AcInstructionFormat >> positionOf: fieldName [
	" Answer the bit-number (where the LSB is 0) the MSB of the field.
	  Assume the field exists, otherwise signal KeyNotFound."
	| i |
	i := -1.
	self bitFields reversed do: [ :assoc |
		i := i + assoc value abs.
		assoc key = fieldName ifTrue: [ ^i ]
	].
	KeyNotFound signalFor: fieldName
]

{ #category : #printing }
AcInstructionFormat >> printOn: aStream [ 
	aStream
		nextPutAll: 'Instruction format ';
		nextPutAll: name;
		nextPutAll: ' '.
	bitFields printElementsOn: aStream
]

{ #category : #accessing }
AcInstructionFormat >> removeFirst [
	self bitFields: self bitFields allButFirst 
]

{ #category : #accessing }
AcInstructionFormat >> widthOf: fieldName [
	"Answer the width of the field (always positive)."
	
	"NB we can't use Dictionary>>newFromAssociations:, because some
	 constant (Integer-named) fields can have the same key.
	 See InstructionFormatTest>>testMcrf"
	self bitFields do: [ :assoc |
		assoc key = fieldName ifTrue: [ ^assoc value abs ]
	].
	KeyNotFound signalFor: fieldName
]
