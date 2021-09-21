Class {
	#name : #AcAsmFormatLiteralTextChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'char'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'factory-chars' }
AcAsmFormatLiteralTextChunk class >> char: c [
	^super new
		char: c;
		yourself 
]

{ #category : #'API - assembly' }
AcAsmFormatLiteralTextChunk >> assembler [
	^self char asParser ==> nil K
]

{ #category : #accessing }
AcAsmFormatLiteralTextChunk >> char [
	^ char
]

{ #category : #accessing }
AcAsmFormatLiteralTextChunk >> char: anObject [
	char := anObject
]

{ #category : #'API - disassembly' }
AcAsmFormatLiteralTextChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	aWriteStream nextPut: char
]

{ #category : #printing }
AcAsmFormatLiteralTextChunk >> printOn: aStream [
	self char printOn: aStream.
	aStream nextPutAll: ' literal chunk'
]
