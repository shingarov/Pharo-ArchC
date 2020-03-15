"
I am the top-level object representing an ISA description.
"
Class {
	#name : #AcProcessorDescription,
	#superclass : #Object,
	#instVars : [
		'memories',
		'regbanks',
		'regs',
		'maps',
		'wordsize',
		'endian',
		'instructionFormats',
		'instructions',
		'regsInGPacket',
		'tgtimm',
		'architectureName',
		'abi'
	],
	#category : #'ArchC-Core'
}

{ #category : #'as yet unclassified' }
AcProcessorDescription class >> systemIcon [
	^Form extent: 12@12 depth: 32 fromArray: (#(
1 1 1 0 1 0 1 0 1 0 1 1
1 1 1 0 1 0 1 0 1 0 1 1
1 1 0 0 0 0 0 0 0 0 0 1
0 0 0 1 1 1 1 1 1 1 0 0
1 1 0 1 0 0 0 0 0 1 0 1
0 0 0 1 0 1 1 1 0 1 0 0
1 1 0 1 0 1 1 1 0 1 0 1
0 0 0 1 0 1 1 1 0 1 0 0
1 1 0 1 0 0 0 0 0 1 0 1
0 0 0 1 1 1 1 1 1 1 0 0
1 1 0 0 0 0 0 0 0 0 0 1
1 1 1 0 1 0 1 0 1 0 1 1
) collect: [ :x | x==1 ifTrue: [ 16rFFFFFFFF ] ifFalse: [ 16rFF000000 ]])
	offset: 0@0

]

{ #category : #accessing }
AcProcessorDescription >> architectureName [
	^ architectureName 
]

{ #category : #accessing }
AcProcessorDescription >> architectureName: aString [
	architectureName := aString
]

{ #category : #'constant width' }
AcProcessorDescription >> constantInstructionWidth [
	"Return something like 32 on something like MIPS,
	or if the ISA is nasty, some generalized-false like nil."
	^32
]

{ #category : #disassembly }
AcProcessorDescription >> disassemble: code [
	"Answer the most-descriptive ProcessorInstruction object encoded by @code.
	Most-descriptive means the most-concretized form of writing."
	^(self disassembleableFormFor: code) disassembleFor: self
]

{ #category : #disassembly }
AcProcessorDescription >> disassembleInt: anInteger [
	"Answer the most-descriptive ProcessorInstruction object encoded by anInteger.
	Most-descriptive means the most-concretized form of writing."
	| candidates |
	candidates := instructions collect: [ :instr |
		[instr decode: anInteger] on: Unsat do: [ nil ] ].
	candidates := candidates reject: [ :instr | instr isNil ].
	candidates isEmpty ifTrue: [self error: 'Invalid instruction encoding'].
	candidates := candidates values.
	^(candidates asSortedCollection:  [ :a :b | a externalBindingBits < b externalBindingBits ]) first
]

{ #category : #'constant width' }
AcProcessorDescription >> disassembleableFormFor: code [
	(code isInteger and: [ self hasConstantInstructionWidth ]) ifTrue: [ ^code asBitVector: self constantInstructionWidth ].
	^code
]

{ #category : #accessing }
AcProcessorDescription >> endian [
	^ endian
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillDecodersFrom: aCollectionOfAssociations [
	| decoderAssociations |
	decoderAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'set_decoder'].
	decoderAssociations := decoderAssociations collect: [ :ass | ass value ].
	decoderAssociations do: [ :ass |
		| instructionName instruction |
		instructionName := ass key.
		instruction := instructions at: instructionName.
		instruction internalBindings: ass value.
	]


]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillFrom: aCollectionOfAssociations [
	memories := self parsedElementsNamed: 'ac_mem' from:  aCollectionOfAssociations.
	regs := self parsedElementsNamed: 'ac_reg' from:  aCollectionOfAssociations.
	regbanks := self parsedElementsNamed: 'ac_regbank' from:  aCollectionOfAssociations.
	wordsize := (aCollectionOfAssociations detect: [ :ass | ass key = 'ac_wordsize' ]) value.
	endian := (aCollectionOfAssociations detect: [ :ass | ass key = 'endian' ]) value.

	self
		fillISAFrom: ((aCollectionOfAssociations detect: [ :ass | ass key = 'ac_isa' ]) value);
		fillSemanticsFrom: ((aCollectionOfAssociations detect: [ :ass | ass key = 'SEMANTICS' ]) value);
		fillLWISEMFrom:    ((aCollectionOfAssociations detect: [ :ass | ass key = 'LWISEM' ]) value).
		
	^self
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillISAFrom: aCollectionOfAssociations [
	self
		fillInstructionFormatsFrom: aCollectionOfAssociations;
		fillMapsFrom: aCollectionOfAssociations; "important that this is done before fillMnemonics"
		fillInstructionsFrom: aCollectionOfAssociations;
		fillDecodersFrom: aCollectionOfAssociations;
		fillMnemonicsFrom: aCollectionOfAssociations 


]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillInstructionFormatsFrom: aCollectionOfAssociations [
	| formatAssociations |
	formatAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'ac_format'].
	formatAssociations := formatAssociations collect: [ :ass | ass value ].
	instructionFormats := Dictionary new.
	formatAssociations do: [ :ass |
		| format |
		(instructionFormats includesKey: ass key asSymbol) ifTrue: [ self error: 'Duplicate instruction format' ].
		format := AcInstructionFormat new.
		format bitFields: ass value.
		format name: ass key.
		instructionFormats at: ass key asSymbol put: format
	]


]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillInstructionsFrom: aCollectionOfAssociations [
	| instructionAssociations |
	instructionAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'ac_instr'].
	instructionAssociations := instructionAssociations collect: [ :ass | ass value ].
	instructions := Dictionary new.
	instructionAssociations do: [ :ass |
		| instruction |
		(instructions includesKey: ass key asSymbol) ifTrue: [ self error: 'Duplicate instruction' ].
		instruction := ProcessorInstruction new.
		instruction
			isa: self;
			name: (ass key);
			format: (instructionFormats  at: ass value asSymbol).
		instructions at: ass key asSymbol put: instruction
	]


]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillLWISEMFrom: aDictionary [
	aDictionary keysAndValuesDo: [ :instrName :lwisem |
		(self instructionAt: instrName) semantics dsl: lwisem ]	

]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillMapsFrom: aCollectionOfAssociations [
	| mapAssociations |
	mapAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'ac_map'].
	mapAssociations := mapAssociations collect: [ :ass | ass value ].
	maps := Dictionary newFromAssociations: mapAssociations
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillMnemonicsFrom: aCollectionOfAssociations [
	| mnemonicAssociations |
	mnemonicAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'set_asm'].
	mnemonicAssociations := mnemonicAssociations collect: [ :ass | ass value ].
	mnemonicAssociations do: [ :ass |
		| instructionName instruction |
		instructionName := ass key.
		instruction := instructions at: instructionName.
		instruction addMnemonic:  ((AcMnemonicParser maps: self maps) parse: ass value).
	]


]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillSemanticsFrom: aCollectionOfAssociations [
	| semanticAssociations |
	tgtimm := (aCollectionOfAssociations detect: [ :ass | ass key = 'tgtimm_size' ]) value.
	abi := (aCollectionOfAssociations detect: [ :ass | ass key = 'abi' ]) value.
	semanticAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'semantic'].
	semanticAssociations := semanticAssociations collect: [ :ass | ass value ].
	semanticAssociations do: [ :ass |
		| instructionName instruction semanticForest |
		instructionName := ass key.
		semanticForest := ass value.
		instruction := instructions at: instructionName.
		semanticForest instruction: instruction.
		"instruction semantics add: semanticForest." "we are in LWISEM, do that here instead"
	]

]

{ #category : #'constant width' }
AcProcessorDescription >> hasConstantInstructionWidth [
	^true "BOGUS"
]

{ #category : #accessing }
AcProcessorDescription >> instructionAt: instructionNameSymbol [
	^instructions at: instructionNameSymbol 
]

{ #category : #accessing }
AcProcessorDescription >> instructionFormats [
	^instructionFormats
]

{ #category : #accessing }
AcProcessorDescription >> instructions [
	^instructions
]

{ #category : #accessing }
AcProcessorDescription >> maps [
	^ maps
	"Do not lazy-initialize here; the Dictionary instance is created in #fillMapsFrom:"
]

{ #category : #private }
AcProcessorDescription >> parsedElementsNamed: key from: aCollectionOfAssociations [
	^(aCollectionOfAssociations select: [ :ass | ass key = key ]) collect: [ :ass | ass value ]

]

{ #category : #printing }
AcProcessorDescription >> printOn: aStream [ 
	aStream nextPutAll: 'AC_ARCH(', self architectureName, ')'
]

{ #category : #accessing }
AcProcessorDescription >> regsInGPacket [
	^ regsInGPacket
]

{ #category : #accessing }
AcProcessorDescription >> regsInGPacket: aSequenceableCollectionOfRT [
	regsInGPacket := aSequenceableCollectionOfRT
]

{ #category : #accessing }
AcProcessorDescription >> tgtimm [
	^ tgtimm 
]

{ #category : #accessing }
AcProcessorDescription >> wordsize [
	^wordsize
]
