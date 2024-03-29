Class {
	#name : #AcDSLCodeBuffer,
	#superclass : #Object,
	#instVars : [
		'address',
		'instructions',
		'cursor'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLCodeBuffer class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
AcDSLCodeBuffer >> address [
	^ address
]

{ #category : #adding }
AcDSLCodeBuffer >> append: aProcessorInstruction [
	instructions add: aProcessorInstruction afterIndex: cursor.
	cursor := cursor + 1.
	^ aProcessorInstruction
]

{ #category : #accessing }
AcDSLCodeBuffer >> bytes [
	^ ByteArray streamContents: [ :s | instructions do: [:i | i emitOn: s ] ]
]

{ #category : #accessing }
AcDSLCodeBuffer >> cursor [
	^ cursor
]

{ #category : #accessing }
AcDSLCodeBuffer >> cursor:anInteger [
	self assert: (anInteger between: 0 and: instructions size).
	cursor := anInteger.
]

{ #category : #utilities }
AcDSLCodeBuffer >> disassembleOn: aStream [
	| pc |

	pc := address.
	instructions do: [:insn |
		| addr |

		addr := pc printStringRadix: 16.
		addr size to: 4 do: [:i | aStream nextPut:$0 ].
		aStream nextPutAll: addr.
		aStream nextPutAll:'    '.
		aStream nextPutAll: insn disassemble.
		aStream cr.
		pc := pc + (insn bitWidth // 8)
	]
]

{ #category : #utilities }
AcDSLCodeBuffer >> disassembled [
	^ String streamContents: [ :s | self disassembleOn: s. ].
]

{ #category : #relocation }
AcDSLCodeBuffer >> fixupBranchTargets [
	| locations insnAddr |

	"Pass 1 - collect all labels and their (relative) addresses:"
	locations := Dictionary new.

	insnAddr := address.
	instructions do: [:insn | 
		insn isLabelInstruction ifTrue: [ 
			locations at: insn symbol put: insnAddr.
		].
		insnAddr := insnAddr + (insn bitWidth // 8)
	].

	"Pass 2 - fix branch instructions"
	self fixupBranchTargetsUsing: locations
]

{ #category : #relocation }
AcDSLCodeBuffer >> fixupBranchTargetsUsing: locations [
	| insnAddr |

	insnAddr := address.
	1 to: instructions size do: [:i |
		| insn |

		insn := instructions at: i.
		(insn isProcessorInstruction and:[insn binaryEncoding isSymbolic]) ifTrue: [ 
			| env |

			env := Dictionary new: locations size.
			locations keysAndValuesDo: [ :label :labelAddr |
				env at: label put: labelAddr - insnAddr
			].
			insn := insn inEnvironment: env.
			instructions at: i put: insn.
		].
		insnAddr := insnAddr + (insn bitWidth // 8)
	].
]

{ #category : #inspecting }
AcDSLCodeBuffer >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 60>

	^ composite fastTable
		title: 'Instructions';
		display: [ 
			| pc insnsWithAddrs |
			
			pc := address.
			insnsWithAddrs := OrderedCollection new: instructions size.
			instructions collect:[:insn |
				insnsWithAddrs add: { insn . pc }.
				pc := pc + (insn bitWidth // 8)
			].
			insnsWithAddrs
		];
		column: 'Address' evaluated: [ :insnAndAddr | insnAndAddr second 	printPaddedWith: $0 to: 6 base: 16  ];
		column: 'Instruction' evaluated: [ :insnAndAddr | insnAndAddr first disassemble ];
		yourself
		"
		selectionPopulate: #selection
			entitled: 'Open key'
			with: [ :table | ( table rawSelection collect: #key ) gtInspectorInterestingObject ];
		beMultiple;
		send: [ :selection | 
			selection
				ifNil: [ nil ]
				ifNotNil: [ selection size = 1
						ifTrue: [ selection anyOne value ]
						ifFalse: [ selection collect: #value ]
					]
			]
		"
]

{ #category : #initialization }
AcDSLCodeBuffer >> initialize [
	address := 0.
	instructions := OrderedCollection new.
	cursor := 0.
]

{ #category : #accessing }
AcDSLCodeBuffer >> instructions [
	^ instructions
]

{ #category : #relocation }
AcDSLCodeBuffer >> relocateTo: newAddress with: ignored [
	address := newAddress.
]
