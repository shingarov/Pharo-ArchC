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
		'bitfields'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcInstructionFormat class >> name: name bitfields: bitFields [
	^ self new initializeWithName: name bitfields: bitFields
]

{ #category : #assertions }
AcInstructionFormat >> assertInvariants [
	self assert: (self bitWidth \\ 8) == 0
]

{ #category : #accessing }
AcInstructionFormat >> binaryEncoding [
	"Answer the bit vector representing this format's binary encoding.
	Most bits in this vector will be variable, so the answer is an
	algebraic expression over field values."
	^ bitfields
			inject: (BitVector empty)
			into: [ :soFar :f | soFar, (f key toBitVector: f value abs) ]
]

{ #category : #accessing }
AcInstructionFormat >> bitFields [
	^ bitfields
]

{ #category : #queries }
AcInstructionFormat >> bitRangeOfField: fieldName [ 
	"Return the bit range of specific fields as interval <highest bit, lowest bit>"
	
	| lo |

	lo := 0.
	self bitFields reversed do: [:bitField | 
		bitField name = fieldName ifTrue: [
			| hi |

			hi := lo + bitField bitWidth - 1.
			^ hi to: lo by: -1
		].
		lo := lo + bitField bitWidth.
	].
	self error: 'No such bitfield: ' , fieldName
]

{ #category : #queries }
AcInstructionFormat >> bitWidth [
	"Answer the width of instructions of this format in bits."

	^ self bitFields sum: [ :bitfield | bitfield bitWidth ].
]

{ #category : #queries }
AcInstructionFormat >> bitWidthOf: fieldName [
	"Answer the width of the field in bits (always positive)."
	
	self bitFields do: [ :bitfield |
		bitfield name = fieldName ifTrue: [ ^ bitfield bitWidth ]  
	].
	KeyNotFound signalFor: fieldName
]

{ #category : #initialization }
AcInstructionFormat >> initializeWithName: aString bitfields: aCollection [
	name := aString.
	bitfields := aCollection.
]

{ #category : #queries }
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

{ #category : #'opcd field' }
AcInstructionFormat >> opcdFieldInterval [
	^self bitRangeOfField: self opcdFieldName
]

{ #category : #'opcd field' }
AcInstructionFormat >> opcdFieldName [
	| opcdFields |
	opcdFields :=  bitfields
		select: [ :f | f key = 'op' or: [ f key = 'opcd' or: [ f key = 'opcode' ] ] ].
	opcdFields size = 1 ifFalse: [self error].
	^opcdFields first key
]

{ #category : #printing }
AcInstructionFormat >> printOn: aStream [ 
	aStream
		nextPutAll: 'Instruction format ';
		nextPutAll: name;
		nextPutAll: ' '.
	bitfields printElementsOn: aStream
]
