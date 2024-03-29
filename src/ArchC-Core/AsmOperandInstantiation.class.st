Class {
	#name : #AsmOperandInstantiation,
	#superclass : #Object,
	#instVars : [
		'operands'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AsmOperandInstantiation class >> operands: opsArray [
	"See AcAsmOperandsParser>>operand.
	ops is essentially a lisp-like list represented in cons pairs.
	Here in Smalltalk, each pair is an Array with: car with: cdr.
	This representation is chosen because this is directly what
	comes out of the parser.
	"
	| car cdr |
	car := opsArray first.
	cdr := opsArray second.
	cdr isNil ifTrue: [ ^self singleOperand: car ].
	"This is for when the operand spans several fields.
	For example, on RISC-V:
	JAL rd, imm4+imm3+imm2+imm1"
	cdr := cdr second. "artefact of parsing"
	cdr operands addFirst: car.
	^cdr
]

{ #category : #'instance creation' }
AsmOperandInstantiation class >> singleOperand: op [
	^self new operands: (OrderedCollection with: op)
]

{ #category : #private }
AsmOperandInstantiation >> asOperandInstantiation [
	^self
]

{ #category : #decoding }
AsmOperandInstantiation >> decode: bitfields accordingTo: format [ 
	| value |

	value := BitVector empty.

	self operands reverseDo: [ :bitfield |
		| bitwidth |

		bitwidth := format bitWidthOf: bitfield.
		value := value , ((bitfields at: bitfield) toBitVector: bitwidth).
	].
	^ value simplify
]

{ #category : #encoding }
AsmOperandInstantiation >> encodeComplexValue: value accordingTo: format [ 
	| bitlen  bitvec  bitindex  bitfields |

	"First, compute total bit-length of the operand and convert
	 operand value into a bit-vector of given length"
	bitlen := operands 
				inject: 0
				into: [:length :field | length + (format bitWidthOf: field) ].
	bitvec := value toBitVector: bitlen.
	 "Then, work from lowest bit to highest bit, extracting
	 portions according to the format"
	bitfields := Dictionary new: operands size.
	bitindex := 0.
	operands do: [:field | 
		| fieldWidth  fieldValue |

		fieldWidth := format bitWidthOf: field.
		fieldValue := bitvec copyFrom: bitindex + fieldWidth - 1 to: bitindex.
		bitfields at: field put: fieldValue.
		bitindex := bitindex + fieldWidth.
	].
	^ bitfields
]

{ #category : #encoding }
AsmOperandInstantiation >> encodeSimpleValue: value [
	^Dictionary new
		at: self operand put: value;
		yourself

]

{ #category : #private }
AsmOperandInstantiation >> encodeValue: value accoringTo: format [
	(value isKindOf: AcAsmOperandModifier) ifTrue: [ ^value encodeInFields: self accordingTo: format ].
	^self encodeSimpleValue: value

]

{ #category : #rewriting }
AsmOperandInstantiation >> inEnvironment: aDictionary format: anAcInstructionFormat [
	^self operands collect: [ :subfield |
		| width v |
		width := anAcInstructionFormat bitWidthOf: subfield.
		v := aDictionary at: subfield.
		v toBitVector: width ]
]

{ #category : #testing }
AsmOperandInstantiation >> isMultiField [
	^self operands size ~= 1
]

{ #category : #accessing }
AsmOperandInstantiation >> operand [
	self isMultiField ifTrue: [ self error ].
	^self operands first
]

{ #category : #accessing }
AsmOperandInstantiation >> operands [
	^ operands
]

{ #category : #accessing }
AsmOperandInstantiation >> operands: anObject [
	operands := anObject
]

{ #category : #printing }
AsmOperandInstantiation >> printOn: aStream [
	aStream nextPutAll: self operands first.
	self isMultiField ifTrue: [ self printRestOfOperandsOn: aStream ]
]

{ #category : #printing }
AsmOperandInstantiation >> printRestOfOperandsOn: aStream [
	self operands allButFirst do: [ :field |
		aStream
			nextPut: $+;
			nextPutAll: field ].
]

{ #category : #private }
AsmOperandInstantiation >> widthAccordingTo: format [
	^self operands inject: 0 into: [ :soFar :currentField |
		soFar + (format bitWidthOf: currentField)
	]
]
