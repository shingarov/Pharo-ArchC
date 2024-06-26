Class {
	#name : #AcDSLCodeObject,
	#superclass : #Object,
	#instVars : [
		'base',
		'exports',
		'instructions'
	],
	#category : #'ArchC-DSL'
}

{ #category : #'instance creation' }
AcDSLCodeObject class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
AcDSLCodeObject >> address [
	"Obsolete, use #base"
	<resource: #obsolete>

	^ self base
]

{ #category : #accessing }
AcDSLCodeObject >> base [
	"Return the base address of this object file.

	 Defaults to 0 (zero), unless it is relocated to a different address.
	 see #relocateTo:with:
	"
	^ base
]

{ #category : #accessing }
AcDSLCodeObject >> bytes [
	"Return a bytearray with binary code. All instructions mys be fully
	 grounded."

	^ ByteArray streamContents: [ :s | instructions do: [:i | i emitOn: s ] ]
]

{ #category : #utilities }
AcDSLCodeObject >> disassembleOn: aStream [
	| pc |

	pc := base.
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
AcDSLCodeObject >> disassembled [
	^ String streamContents: [ :s | self disassembleOn: s. ].
]

{ #category : #utilities }
AcDSLCodeObject >> export: symbol [
	exports add: symbol
]

{ #category : #accessing }
AcDSLCodeObject >> exports [
	"Return a map (Dictionary) mapping all exports (exported labels) 
	 to their corresponding addresses, respecing current base address.
	"

	| exportMap addr |

	exportMap := Dictionary new: exportMap size.
	addr := base.
	instructions do: [:insn |
		(insn isLabelInstruction and:[exports includes: insn symbol]) ifTrue: [
			exportMap at: insn symbol put: addr.
		].
		addr := addr + (insn bitWidth // 8)
	].
	^ exportMap
]

{ #category : #relocation }
AcDSLCodeObject >> fixupBranchTargets [
	self fixupBranchTargetsUsing: self labels
]

{ #category : #relocation }
AcDSLCodeObject >> fixupBranchTargetsUsing: locations [
	| insnAddr |

	insnAddr := base.
	1 to: instructions size do: [:i |
		| insn |

		insn := instructions at: i.
		(insn isProcessorInstruction and:[insn binaryEncoding isSymbolic]) ifTrue: [ 
			| env |

			env := Dictionary new: locations size.
			locations keysAndValuesDo: [ :label :labelAddr |
				env at: label asString put: labelAddr - insnAddr
			].
			insn := insn inEnvironment: env.
			instructions at: i put: insn.
		].
		insnAddr := insnAddr + (insn bitWidth // 8)
	].
]

{ #category : #inspecting }
AcDSLCodeObject >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 60>

	^ composite fastTable
		title: 'Instructions';
		display: [ 
			| pc insnsWithAddrs |
			
			pc := base.
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
AcDSLCodeObject >> initialize [
	base := 0.
	exports := Set new.
	instructions := OrderedCollection new.
]

{ #category : #accessing }
AcDSLCodeObject >> instructions [
	"Return code as a sequence of AcInstructions. Users are
	 allowed to modify this sequence in place to add/remove/replace
	 instructions."

	^ instructions
]

{ #category : #accessing }
AcDSLCodeObject >> labels [
	"Return a map (Dictionary) mapping all labels to their corresponding
	 addresses, respecing current base address.

	 This map includes both, exported and internal labels.
	"

	| labelMap addr |

	labelMap := Dictionary new.
	addr := base.
	instructions do: [:insn |
		insn isLabelInstruction ifTrue: [
			labelMap at: insn symbol put: addr.
		].
		addr := addr + (insn bitWidth // 8)
	].
	^ labelMap
]

{ #category : #relocation }
AcDSLCodeObject >> relocateTo: address with: ignored [
	base := address.
]

{ #category : #accessing }
AcDSLCodeObject >> relocations [
	| addr relocs |

	addr := base.
	relocs := OrderedCollection new.
	instructions do: [:insn |
		insn relocation notNil ifTrue: [
			insn relocation address: addr.
			relocs add: insn relocation.
		].
		addr := addr + (insn bitWidth // 8).
	].
	^ relocs
]

{ #category : #accessing }
AcDSLCodeObject >> size [
	"Return the size of code in bytes"

	^ instructions inject: 0 into: [:size :insn | size + (insn bitWidth // 8) ]
]
