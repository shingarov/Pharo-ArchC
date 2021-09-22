"
I am a dummy object (possibly standing for a processor instruction)
knowing my InstructionFormat.
"
Class {
	#name : #MockFormatPoznavach,
	#superclass : #Object,
	#instVars : [
		'pdl',
		'format'
	],
	#category : #'ArchC-Core-Tests'
}

{ #category : #formatting }
MockFormatPoznavach class >> format: formatName pdl: pdl [
	| format |
	format := pdl instructionFormats at: formatName asString.
	^self new
		pdl: pdl;
		format: format;
		yourself

]

{ #category : #accessing }
MockFormatPoznavach >> format [
	^ format
]

{ #category : #accessing }
MockFormatPoznavach >> format: anObject [
	format := anObject
]

{ #category : #'as yet unclassified' }
MockFormatPoznavach >> inEnvironment: fieldValues [ 
	"Quick hack to assist the forward-assemble side of AcSimpleMnemonicTest.
	Just return the operands."
	^fieldValues 
]

{ #category : #accessing }
MockFormatPoznavach >> isa [
	^ pdl

]

{ #category : #accessing }
MockFormatPoznavach >> pdl [
	^ pdl
]

{ #category : #accessing }
MockFormatPoznavach >> pdl:something [
	pdl := something.
]
