Class {
	#name : #AcMnemonicSpec,
	#superclass : #Object,
	#instVars : [
		'format',
		'operands',
		'constraints'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
AcMnemonicSpec class >> format: aMnemonicFormat operandsAndConstraints: anArray [
	^self new
		format: aMnemonicFormat ;
		operands: (anArray reject: [ :op | op isKindOf: AcMnemonicConstraint ]);
		constraints: (anArray select: [ :op | op isKindOf: AcMnemonicConstraint ]);
		yourself
]

{ #category : #accessing }
AcMnemonicSpec >> constraints [
	^ constraints
]

{ #category : #accessing }
AcMnemonicSpec >> constraints: anObject [
	constraints := anObject
]

{ #category : #API }
AcMnemonicSpec >> disassembleEnv: aDictionary [
	"Given the operand environment aDictionary,
	 answer a string of disassembly, or nil if
	 the environment does not fit this spec.
	 The answer is given in the form of Association,
	 whose key is the string of disassembly and the
	 value is an integer indicating the number of 
	 bound operands.  The latter is used to select
	 the most sepecific mnemonic form.
	OPERAND VALUES IN aDictionary MUST BE CONCRETE."
	
	| s operandValues |
	"First, see if we satisfy the constraints..."
	constraints do: [ :constraint |
		(constraint satisfy: aDictionary) ifFalse: [ ^nil ] ].
	"...if we got here, we do."
	operandValues := operands collect: [ :op | op value: aDictionary ].
	s := format value: operandValues asOrderedCollection.
	^ s -> constraints size
]

{ #category : #accessing }
AcMnemonicSpec >> format [
	^ format
]

{ #category : #accessing }
AcMnemonicSpec >> format: anObject [
	format := anObject
]

{ #category : #accessing }
AcMnemonicSpec >> operands [
	^ operands
]

{ #category : #accessing }
AcMnemonicSpec >> operands: anArray [
	
	operands := anArray 
]
