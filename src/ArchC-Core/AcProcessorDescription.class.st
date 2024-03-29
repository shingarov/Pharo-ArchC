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
		'opcodeFieldName',
		'opcodeFieldInterval'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcProcessorDescription class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

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
AcProcessorDescription >> addSyntax: aParser [ 
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
AcProcessorDescription >> assemble: aStringOrArray"of Strings" on: aStream [
	aStringOrArray isString ifTrue: [ 
		(self assemble: aStringOrArray) emitOn: aStream
	] ifFalse: [ 
		aStringOrArray do: [:each | 
			(self assemble: each) emitOn: aStream
		].
	].

	"
	ByteArray streamContents: [ :s |
		AcProcessorDescriptions riscv
			assemble: #('addi a5, a0, 0'
						'bne a5, a3, -12')
			on: s
	]
	"

]

{ #category : #'as yet unclassified' }
AcProcessorDescription >> assembleLines: source [
	^(source lines reject: [ :aLine |
		aLine isEmpty or: [
			(aLine beginsWith: '#') or:
				[ aLine allSatisfy: #isSeparator ] ] ]) collect: [ :aRealLine |
		(self assemble: aRealLine) emit32
	]
]

{ #category : #assembly }
AcProcessorDescription >> assembler [
	^instructionMnemonics 
]

{ #category : #assertions }
AcProcessorDescription >> assertInvariants [
	instructionFormats do: [:format | format assertInvariants ].
	instructions do: [:insn | insn assertInvariants ].

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
AcProcessorDescription >> decodeBits: aBitVector [ 
	"Answer the most-descriptive ProcessorInstruction object encoded by anInteger.
	 Most-descriptive means the most-concretized form of writing."
	
	| candidates |

	candidates := opcodeDecoder preDecodeBits: aBitVector.
	candidates := candidates collect: [:instr | instr decodeBits: aBitVector ].
	candidates := candidates reject: [:instr | instr isNil ].
	candidates isEmpty ifTrue: [ IllegalInstruction signalWith: aBitVector ].
	^ (candidates 
		asSortedCollection: [:a :b | a externalBindingBits < b externalBindingBits ]) 
			first
]

{ #category : #'constant width' }
AcProcessorDescription >> decodeableFormFor: code [
	self hasConstantInstructionWidth ifTrue: [
		(code isKindOf: ByteArray)"Sigh, Pharo has no #isByteArray"
			ifTrue: [ 
				code size == (self constantInstructionWidth // 8) 
					ifFalse: [ self error: 'Invalid bytes (too few or too much)' ].
				^code toBitVectorEndian: self endian ].
		(code isCollection and:[code isSequenceable])
			ifTrue:[ ^code ].
		^code toBitVector: self constantInstructionWidth
	] ifFalse: [ 
		self error: 'Not applicable for variable-width ISA'
	].
]

{ #category : #disassembly }
AcProcessorDescription >> disassemble: binaryEncoding [ 
	^(self decode: binaryEncoding) disassemble
]

{ #category : #accessing }
AcProcessorDescription >> endian [
	^ endian
]

{ #category : #'as yet unclassified' }
AcProcessorDescription >> endian: anEndian [
	endian := anEndian
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

	aCollectionOfAssociations do: [:each | 
		each key = 'ac_isa' ifTrue: [ self fillISAFrom: each value ]
	].

	instructionMnemonics := PPChoiceParser withAll: instructionMnemonics.

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
	self hasOpcodeField ifTrue: [
		opcodeDecoder := AcOpcodeDecoder for: self
	] ifFalse: [
		opcodeDecoder := AcInstructionDecoder for: self
	].
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillInstructionFormatsFrom: aCollectionOfAssociations [
	aCollectionOfAssociations do: [:assoc | 
		assoc key = 'ac_format' ifTrue: [ 
			| format |

			format := assoc value.
			(instructionFormats includesKey: format name) ifTrue: [ 
				self error: 'Duplicate definition of instruction format "', format name , '"!'.
			].
			instructionFormats at: format name asSymbol put: format.
		].        
	].
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillInstructionsFrom: aCollectionOfAssociations [
	aCollectionOfAssociations do: [:assoc |  
		assoc key = 'ac_instr' ifTrue: [ 
			| instruction |

			instruction := assoc value.
			(instructions includesKey: instruction name) ifTrue: [ 
				self error: 'Duplicate instruction "' , instruction name , '"'
			].
			instruction isa: self.
			instructions at: instruction name put: instruction.
		].
	].
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillMapsFrom: aCollectionOfAssociations [
	aCollectionOfAssociations do: [ :ass |
		ass key = 'ac_map' ifTrue: [ 
			maps at: ass value name put: ass value
		].
	].
]

{ #category : #'collaboration with parser' }
AcProcessorDescription >> fillMnemonicsFrom: aCollectionOfAssociations [
	"The argument represents all statements -- such as ac_format, ac_instr etc --
	collected during parsing <isaname>_isa.ac.
	Filter the set_asm statements, parse them, and attach them to their instructions."
	| associations |
	
	associations := aCollectionOfAssociations select: [ :ass | ass key = 'set_asm']
		thenCollect: [ :ass | ass value ].
	
	"At this point we are looking at an array of associations from the instruction name
	to the verbatim textual definition of the instruction mnemonic
	(which can be more than one per instruction)"
	AcSetAsmParser processAssociations: associations in: self.
	instructions do: [:instruction | instruction syntax sort: [ :a :b | a isMoreOrEquallySpecificThan: b  ] ].
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

{ #category : #queries }
AcProcessorDescription >> hasOpcodeField [
	"Return true, if this ISA (model) has a single opcode field.
	 Return false otherwise.

	 Most ISA (models) do, but some don't (like AArch64).
	"
	| opcdFieldName |

	opcdFieldName := instructionFormats values anyOne opcdFieldName.
	instructionFormats do: [:format | 
		(format hasField: opcdFieldName) ifFalse: [ ^ false ].
	].
	^ true.
]

{ #category : #initialization }
AcProcessorDescription >> initialize [
	super initialize.

	"  memories := nil."
	"  regbanks := nil."
	"  regs := nil."
	maps := Dictionary new.
	"  wordsize := nil."
	"  endian := nil."
	instructionFormats := Dictionary new.
	instructions := Dictionary new.
	"  regsInGPacket := nil."
	"  tgtimm := nil."
	"  architectureName := nil."
	"  abi := nil."
	instructionMnemonics := OrderedCollection new.
	"  opcodeDecoder := nil."
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
	opcodeFieldInterval isNil ifTrue: [ 
		opcodeFieldInterval := instructionFormats values anyOne bitRangeOfField: self opcdFieldName  
	].
	^ opcodeFieldInterval
]

{ #category : #'opcd field' }
AcProcessorDescription >> opcdFieldName [
	opcodeFieldName isNil ifTrue: [
		self assert: self hasOpcodeField.
		opcodeFieldName := instructionFormats values anyOne opcdFieldName.
	].
	^ opcodeFieldName
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
