"
I represent an instruction where only ""constant"" fields, such as the opcode, are known.
NB: This class is an abstract template from which ProcessorInstructions are instantiated.
It is not, however, ""purely abstract"", because its instances exist -- they are values in the ""instructions"" Dictionary in the PDL.
However, even when an instruction is instantiated as ""fully ungrounded"", it is an instance of ProcessorInstruction.
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
	#category : #'ArchC-Core-Core'
}

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> addMnemonic: aMnemonicSpec [
	self mnemonics add: aMnemonicSpec
]

{ #category : #'as yet unclassified' }
ProcessorInstructionDeclaration >> binaryEncoding [
	^format binaryEncoding 
]

{ #category : #private }
ProcessorInstructionDeclaration >> copyWithBinary: aBinaryEncoding [
	^(isa grounder ground: self)
		binaryEncoding: aBinaryEncoding;
		yourself 
	
]

{ #category : #disassembly }
ProcessorInstructionDeclaration >> decode: aBV [
	"Answer a copy of the receiver concretized down to be
	consistent with the binary encoding given by aBV.
	Answer nil if this is impossible, -- e.g., if the opcode
	contained in aBV is different from the receiver's opcode.
	
	The most straightforward scenario is when the receiver
	is an instruction declaration (i.e. none of the operands
	are known) and the argument is concrete (non-symbolic),
	resulting in a fully-grounded instruction; but this does
	not *necessarily* have to be the only possible scenario:
	some operands could be known already, and aBV could
	contain some unknown bits."
	aBV isAST ifFalse: [^self decode: (aBV toBitVector: 32)].
	(self fitsBinary: aBV) ifFalse: [ ^nil ].
	^self copyWithBinary: aBV
]

{ #category : #'as yet unclassified' }
ProcessorInstructionDeclaration >> fitsBinary: aBV [
	| dict |
	dict := format parseBinary: aBV.
	internalBindings keysAndValuesDo: [ :k :v |
		(dict at: k) = v ifFalse: [ ^false ]].
	^true
]

{ #category : #accessing }
ProcessorInstructionDeclaration >> format [
	^ format
]

{ #category : #'parser access for construction' }
ProcessorInstructionDeclaration >> format: anObject [
	format := anObject
]

{ #category : #emitting }
ProcessorInstructionDeclaration >> inEnvironment: env [
	"Answer a ProcessorInstruction where the operands are bound according to env.
	It is not necessary to define values for ALL operands; if some operands are
	left unspecified, those bits in the emitted binary will be symbolic.
	NB: unlike #decode: which returns a model, this method's answer is the most general."
	^self copyWithBinary: (self leastKnownBinary inEnvironment: env)
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

{ #category : #private }
ProcessorInstructionDeclaration >> leastKnownBinary [
	^self format binaryEncoding inEnvironment: self internalBindings
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

{ #category : #'as yet unclassified' }
ProcessorInstructionDeclaration >> opcode [
	^internalBindings at: isa opcdFieldName 
]

{ #category : #printing }
ProcessorInstructionDeclaration >> printOn: aStream [ 
	aStream nextPutAll: self name.
	aStream nextPutAll: ' [a '.
	aStream nextPutAll: isa architectureName.
	aStream nextPutAll: ' instruction]'.
]

{ #category : #access }
ProcessorInstructionDeclaration >> rangeOf: fieldName [
	"Answer the interval of bit-positions of the requested field."
	| start stop |
	start := format positionOf: fieldName.
	stop := start + 1 - (format widthOf: fieldName).
	^Interval from: start to: stop by: -1
]
