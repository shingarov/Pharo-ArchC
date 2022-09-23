Class {
	#name : #AcInstructionDecoder,
	#superclass : #Object,
	#instVars : [
		'isa'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcInstructionDecoder class >> for: aPDL [
	^ self basicNew 
		initializeWithPDL: aPDL;
		yourself
]

{ #category : #decoding }
AcInstructionDecoder >> decodeBits: aBitVector [ 
	"Answer the most-descriptive ProcessorInstruction object encoded by anInteger.
	 Most-descriptive means the most-concretized form of writing."

	| candidates |

	candidates := self preDecodeBits: aBitVector.
	candidates := candidates collect: [:instr | instr decodeBits: aBitVector ].
	candidates := candidates reject: [:instr | instr isNil ].
	candidates isEmpty ifTrue: [
		IllegalInstruction signalWith: aBitVector
	].
	^ (candidates 
		asSortedCollection: [:a :b | a externalBindingBits < b externalBindingBits ]) 
			first
]

{ #category : #initialization }
AcInstructionDecoder >> initializeWithPDL: aPDL [
	isa := aPDL
]

{ #category : #'decoding-private' }
AcInstructionDecoder >> preDecodeBits: aBitVector [
	"Given an encoding (as `aBitVector`), returns a set of instruction declarations
	 that may be encoded by that encoding. This is to speed up decoding as it limits
	 the number of instruction declarations to be 'probed'.

	 This method must be consevative, that is, it's okay to return more instruction
	 but not less!
	"

	"By default we return all instructions, this is safe but slow. See subclasses
	 for better implementations."
	^ isa instructions
]
