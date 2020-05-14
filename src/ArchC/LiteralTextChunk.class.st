Class {
	#name : #LiteralTextChunk,
	#superclass : #AcMnemonicChunk,
	#instVars : [
		'char'
	],
	#category : #'ArchC-Core'
}

{ #category : #'factory-chars' }
LiteralTextChunk class >> char: c [
	^self new
		char: c;
		yourself 
]

{ #category : #'API - assembly' }
LiteralTextChunk >> assembler [
	^self char asParser ==> [ :_ | nil ]
]

{ #category : #accessing }
LiteralTextChunk >> char [
	^ char
]

{ #category : #accessing }
LiteralTextChunk >> char: anObject [
	char := anObject
]

{ #category : #'API - disassembly' }
LiteralTextChunk >> disassembleTo: aWriteStream inEnvironment: e [
	aWriteStream nextPut: char
]
