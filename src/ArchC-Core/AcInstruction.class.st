"
AcInstruction is an abstract base class for real processor
instructions and for pseudo-instructions like label.

It defines the base API of an ""instruction"" - by ""instruction""
we mean anything that may appear in instruction stream generated
by ArchC based compiler (see package ArchC-DSL and class 
AcDSLCodeBuffer).

Every instruction - being it real processor instruction, instruction
declaration or pseudo-instruction can be annotated by any number of
annotations. An annotation can be any arbitrary object but at most
once. That means a given instruction cannot have two annotations of
the same class. See protocol 'annotations'.

"
Class {
	#name : #AcInstruction,
	#superclass : #Object,
	#instVars : [
		'annotations'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #queries }
AcInstruction class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == AcInstruction.
]

{ #category : #annotations }
AcInstruction >> annotationAdd: anObject [ 
	annotations isNil ifTrue: [
		annotations := Set with: anObject
	] ifFalse: [
		| annotation |

		annotation := self annotationAt: anObject class.
		annotation notNil ifTrue: [ 
			self error: 'Instruction already annotated with ', anObject class name.
			"You may want to #annotationAddOrReplace:"
		].
		annotations add: anObject
	].
]

{ #category : #annotations }
AcInstruction >> annotationAddOrReplace: anObject [ 
	annotations isNil ifTrue: [
		annotations := Set with: anObject
	] ifFalse: [
		| annotation |

		annotation := self annotationAt: anObject class.
		annotation notNil ifTrue: [ 
			annotations remove: annotation.
		].
		annotations add: anObject
	].
]

{ #category : #annotations }
AcInstruction >> annotationAt: aClass [ 
	annotations isNil ifTrue: [
		^ nil
	].
	^ annotations detect: [:e | e class == aClass ] ifNone: nil
]

{ #category : #annotations }
AcInstruction >> annotationRemove: anObject [ 
	annotations notNil ifTrue: [
		annotations remove: anObject ifAbsent: nil
	].
]

{ #category : #annotations }
AcInstruction >> annotationRemoveByKey: aClass [ 
	| annotation |

	annotation := self annotationAt: aClass.
	annotation notNil ifTrue: [
		self annotationRemove: annotation.
	].
]

{ #category : #annotations }
AcInstruction >> annotations [
	annotations isNil ifTrue: [ ^ #() ].
	^ annotations
]

{ #category : #annotations }
AcInstruction >> annotations: aCollection [
	"Set annotations. Old annotations (if any) are discarded."

	aCollection notNil ifTrue: [
		annotations := nil.
	].
	aCollection notNil ifTrue: [
		aCollection do: [:each | self annotationAdd: each ]
	]
]

{ #category : #converting }
AcInstruction >> asByteArray [
	"Return bytes encoding this instruction. The instruction
	 must be fully grounded (that is: not symbolic) otherwise 
	 an error is thrown.
	"
	^ ByteArray streamContents: [ :s | self emitOn: s ]
]

{ #category : #accessing }
AcInstruction >> binaryEncoding [
	^ self subclassResponsibility
]

{ #category : #accessing }
AcInstruction >> bitWidth [
	"Answer the width of instructions in bits."

	^ self subclassResponsibility
]

{ #category : #'encoding / decoding' }
AcInstruction >> decodeBits: aBitVector [
   "Answer a copy of the receiver concretized down to be
	consistent with the binary encoding given by `aBitVector`.
	Answer `nil` if this is impossible, -- e.g., if the opcode
	contained in `aBitVector` is different from the receiver's 
	opcode.

	The most straightforward scenario is when the receiver
	is an instruction declaration (i.e. none of the operands
	are known) and the argument is concrete (non-symbolic),
	resulting in a fully-grounded instruction; but this does
	not *necessarily* have to be the only possible scenario:
	some operands could be known already, and aBV could
	contain some unknown bits."

	^ self subclassResponsibility
]

{ #category : #'encoding / decoding' }
AcInstruction >> disassemble [
	"Return string representing receiver in an assembly language."
	^ self subclassResponsibility
]

{ #category : #'encoding / decoding' }
AcInstruction >> emitOn: aStream [
	"Emit (encode) instruction on given (binary) stream. The instruction
	 must be fully grounded (that is: not symbolic) otherwise an error is
	 thrown.
	"
	self subclassResponsibility
]

{ #category : #accessing }
AcInstruction >> format [
	^ self subclassResponsibility
]

{ #category : #converting }
AcInstruction >> inEnvironment: env [
	"Answer an instruction where the operands (if any) are bound according to
	 given environment (a dictionary or dictionary-like object).

	 It is not necessary to define values for ALL operands; if some operands are
	 left unspecified, those bits in the resulting instruction will be symbolic.
	 NB: unlike #decode: which returns a model, this method's answer is the most general."

	^ self subclassResponsibility
]

{ #category : #testing }
AcInstruction >> isLabelInstruction [
	^ false
]

{ #category : #testing }
AcInstruction >> isProcessorInstruction [
	^ false
]

{ #category : #testing }
AcInstruction >> isPseudoInstruction [
	^ false
]

{ #category : #accessing }
AcInstruction >> name [
	^ self subclassResponsibility
]
