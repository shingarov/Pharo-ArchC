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

{ #category : #testing }
AcAsmFormatCompositeChunk >> notEmpty [
	^ subchunks notEmpty

]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> subchunks [
	^ subchunks
]

{ #category : #accessing }
AcAsmFormatCompositeChunk >> subchunks:aSequenceableCollection [
	subchunks := aSequenceableCollection.

]
