Class {
	#name : #AcDSLCodeBuffer,
	#superclass : #Object,
	#instVars : [
		'address',
		'instructions'
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
	^ instructions add: aProcessorInstruction
]

{ #category : #accessing }
AcDSLCodeBuffer >> bytes [
	^ ByteArray streamContents: [ :s | instructions do: [:i | i emitOn: s ] ]
]

{ #category : #utilities }
AcDSLCodeBuffer >> disassembleOn: aStream [
	| cursor |

	cursor := address.
	instructions do: [:insn |
		| addr |

		addr := cursor printStringRadix: 16.
		addr size to: 4 do: [:i | aStream nextPut:$0 ].
		aStream nextPutAll: addr.
		aStream nextPutAll:'    '.
		aStream nextPutAll: insn disassemble.
		aStream cr.
		cursor := cursor + (insn width // 8)
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

{ #category : #initialization }
AcDSLCodeBuffer >> initialize [
	address := 0.
	instructions := OrderedCollection new.
]

{ #category : #accessing }
AcDSLCodeBuffer >> instructions [
	^ instructions
]

{ #category : #relocation }
AcDSLCodeBuffer >> relocateTo: newAddress with: ignored [
	address := newAddress.
]
