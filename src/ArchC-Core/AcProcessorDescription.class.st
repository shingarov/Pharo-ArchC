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
		'abi',
		'instructionMnemonics',
		'opcodeDecoder',
		'grounder'
	],
	#category : #'ArchC-Core-Core'
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

{ #category : #'collaboration with parser' }
AcProcessorDescription >> addMnemonic: aParser [
	instructionMnemonics add: aParser 

]

{ #category : #accessing }
AcProcessorDescription >> architectureName [
	^ architectureName 
]

{ #category : #accessing }
AcProcessorDescription >> architectureName: aString [
	architectureName := aString
]

{ #category : #assembly }
AcProcessorDescription >> assemble: aLineOfAssembly [
	| instr |
	instr := self assembler parse: aLineOfAssembly.
	instr isPetitFailure ifTrue: [ AssemblerParseError signal ].
	^instr
]

{ #category : #assembly }
AcProcessorDescription >> assembler [
	^instructionMnemonics 
]

{ #category : #'constant width' }
AcProcessorDescription >> constantInstructionWidth [
	"Return something like 32 on something like MIPS,
	or if the ISA is nasty, some generalized-false like nil."
	^32
]

{ #category : #disassembly }
AcProcessorDescription >> decode: code [
	"Answer the most-descriptive ProcessorInstruction object encoded by @code.
	Most-descriptive means the most-concretized form of writing."
	^(self decodeableFormFor: code) decodeFor: self
]

{ #category : #disassembly }
AcProcessorDescription >> decodeInt: anInteger [
	"Answer the most-descriptive ProcessorInstruction object encoded by anInteger.
	Most-descriptive means the most-concretized form of writing."
	| candidates |
	candidates := opcodeDecoder instructionsWithOpcodeFitting: anInteger.
	candidates := candidates collect: [ :instr | instr decode: anInteger].
	candidates := candidates reject: [ :instr | instr isNil ].
	candidates isEmpty ifTrue: [self error: 'Invalid instruction encoding'].
	^(candidates asSortedCollection:  [ :a :b | a externalBindingBits < b externalBindingBits ]) first
]

{ #category : #'constant width' }
AcProcessorDescription >> decodeableFormFor: code [
	(code isInteger and: [ self hasConstantInstructionWidth ]) ifTrue: [ ^code toBitVector: self constantInstructionWidth ].
	((code isKindOf: ByteArray)  and: [ self hasConstantInstructionWidth ])
		ifTrue: [ ^self endian 
					ifBig: [code asBitVectorBE]
					ifLittle: [code asBitVectorLE]].
	^code
]

{ #category : #disassembly }
AcProcessorDescription >> disassemble: binaryEncoding [ 
	^(self decode: binaryEncoding) disassemble
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
		fillSemanticsFrom: ((aCollectionOfAssociations detect: [ :ass | ass key = 'SEMANTICS' ]) value).
"		fillLWISEMFrom:    ((aCollectionOfAssociations detect: [ :ass | ass key = 'LWISEM' ]) value)."
		
	^self
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillISAFrom: aCollectionOfAssociations [
	self
		fillInstructionFormatsFrom: aCollectionOfAssociations;
		fillMapsFrom: aCollectionOfAssociations; "important that this is done before fillMnemonics"
		fillInstructionsFrom: aCollectionOfAssociations;
		fillDecodersFrom: aCollectionOfAssociations;
		fillMnemonicsFrom: aCollectionOfAssociations.
	opcodeDecoder := OpcodeDecoder for: self


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
		instruction := ProcessorInstructionDeclaration new.
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
	| mapAssociations m |
	mapAssociations := aCollectionOfAssociations select: [ :ass |
		ass key = 'ac_map'].
	m := mapAssociations collect: [ :ass | ass value name2self ].
	maps := Dictionary newFromAssociations: m
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillMnemonicsFrom: aCollectionOfAssociations [
	"The argument represents all statements -- such as ac_format, ac_instr etc --
	collected during parsing <isaname>_isa.ac.
	Filter the set_asm statements, parse them, and attach them to their instructions."
	| associations |
	instructionMnemonics := OrderedCollection new.
	
	associations := aCollectionOfAssociations select: [ :ass | ass key = 'set_asm']
		thenCollect: [ :ass | ass value ].
	
	"At this point we are looking at an array of associations from the instruction name
	to the verbatim textual definition of the instruction mnemonic
	(which can be more than one per instruction)"
	AcSetAsmParser processAssociations: associations in: self.
	instructionMnemonics := PPChoiceParser withAll: instructionMnemonics 
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

{ #category : #accessing }
AcProcessorDescription >> grounder [
	grounder isNil ifTrue: [ grounder := InstructionGrounder new ].
	^ grounder
]

{ #category : #accessing }
AcProcessorDescription >> gtViewInstructionsOn: aView [
	<gtView>
	^ aView list
		title: 'Instructions';
		priority: 8;
		items: [self instructions values];
		itemText: [ :insn | insn name asRopedText ]
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

{ #category : #'opcd field' }
AcProcessorDescription >> opcdFieldInterval [
	^instructionFormats values anyOne opcdFieldInterval 
]

{ #category : #'opcd field' }
AcProcessorDescription >> opcdFieldName [
	^instructionFormats values anyOne opcdFieldName 
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
