"
I represent an instruction where only ""constant"" fields, such as the opcode, are known.
NB: This class is purely abstract, existing just for separation of code.  Even when an instruction is initially instantiated as ""fully ungrounded"", it is an instance of ProcessorInstruction.
"
Class {
	#name : #ProcessorInstructionDeclaration,
	#superclass : #Object,
	#instVars : [
		'name',
		'format',
		'internalBindings',
		'mnemonics',
		'semantics',
		'isa'
	],
	#category : #'ArchC-Core'
}

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> addMnemonic: aMnemonicSpec [
	self mnemonics add: aMnemonicSpec
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> format [
	^ format
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> format: anObject [
	format := anObject
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> initializeBinaryEncoding [
	self subclassResponsibility 
	"binaryEncoding := self leastKnownBinary"
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> internalBindings [
	^ internalBindings
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> internalBindings: aDict [
	internalBindings := aDict
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> isa [
	^ isa
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> isa: anObject [
	isa := anObject
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> mnemonics [
	mnemonics isNil ifTrue: [ mnemonics := Set new ].
	^ mnemonics
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> name [
	^ name
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> name: anObject [
	name := anObject
]

{ #category : #GT }
ProcessorInstructionDeclaration >> nameForInspector [
	^self name
]
