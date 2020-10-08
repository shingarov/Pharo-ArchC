"
I am a dummy object (possibly standing for a processor instruction)
knowing my InstructionFormat.
"
Class {
	#name : #MockFormatPoznavach,
	#superclass : #Object,
	#instVars : [
		'format'
	],
	#category : #'ArchC-Core-Tests'
}

{ #category : #formatting }
MockFormatPoznavach class >> format: formatName pdl: pdl [
	| f |
	f := pdl instructionFormats at: formatName asString.
	^self new
		format: f;
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
