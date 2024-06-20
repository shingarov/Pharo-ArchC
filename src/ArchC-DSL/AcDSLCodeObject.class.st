Class {
	#name : #AcDSLCodeObject,
	#superclass : #Object,
	#instVars : [
		'address',
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
	^ address
]

{ #category : #accessing }
AcDSLCodeObject >> bytes [
	^ ByteArray streamContents: [ :s | instructions do: [:i | i emitOn: s ] ]
]

{ #category : #utilities }
AcDSLCodeObject >> disassembleOn: aStream [
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
AcDSLCodeObject >> disassembled [
	^ String streamContents: [ :s | self disassembleOn: s. ].
]

{ #category : #relocation }
AcDSLCodeObject >> fixupBranchTargets [
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
AcDSLCodeObject >> fixupBranchTargetsUsing: locations [
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
AcDSLCodeObject >> gtInspectorInstructionsIn: composite [
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
AcDSLCodeObject >> initialize [
	address := 0.
	instructions := OrderedCollection new.
]

{ #category : #accessing }
AcDSLCodeObject >> instructions [
	^ instructions
]

{ #category : #relocation }
AcDSLCodeObject >> relocateTo: newAddress with: ignored [
	address := newAddress.
]

{ #category : #accessing }
AcDSLCodeObject >> relocations [
	| addr relocs |

	addr := address.
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
