Class {
	#name : #AcAsmFormatCompositeChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'subchunks'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
AcAsmFormatCompositeChunk class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> at: index [
	^ subchunks at: index
]

{ #category : #initialization }
AcAsmFormatCompositeChunk >> initialize [
	"Invoked when a new instance is created."

	"  please change as required (and remove this comment)"
	subchunks := #()

	"  super initialize.   -- commented since inherited method does nothing"

]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> instruction: aProcessorInstructionDeclaration [
	super instruction: aProcessorInstructionDeclaration.
	subchunks do: [:subchunk | subchunk instruction: aProcessorInstructionDeclaration ].
]

{ #category : #testing }
AcAsmFormatCompositeChunk >> isEmpty [
	^ subchunks isEmpty

]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> modifier [
	| builtins |

	builtins := subchunks select: [ :each | each isBuiltinChunk ].
	builtins isEmpty ifTrue: [ ^ NoOperandModifier ].
	builtins size == 1 ifTrue: [ ^ builtins first modifier ].
	self error: 'Oops, more than one builtin chunk!'.
]

{ #category : #testing }
AcAsmFormatCompositeChunk >> notEmpty [
	^ subchunks notEmpty

]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> size [
	^ subchunks size
]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> subchunks [
	^ subchunks
]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> subchunks:aSequenceableCollection [
	subchunks := aSequenceableCollection.

]
