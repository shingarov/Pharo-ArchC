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
	^super new
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
LiteralTextChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	aWriteStream nextPut: char
]

{ #category : #printing }
LiteralTextChunk >> printOn: aStream [
	self char printOn: aStream.
	aStream nextPutAll: ' literal chunk'
]
