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

{ #category : #initialization }
AcDSLCodeBuffer >> initialize [
	address := 0.
	instructions := OrderedCollection new.
]

{ #category : #relocation }
AcDSLCodeBuffer >> relocateTo: newAddress with: ignored [
	address := newAddress.
]
