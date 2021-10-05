Class {
	#name : #AcAsmFormatLiteralTextChunk,
	#superclass : #AcAsmFormatChunk,
	#instVars : [
		'text'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'factory-chars' }
AcAsmFormatLiteralTextChunk class >> char: c [
	^self new
		text: c asString;
		yourself 

]

{ #category : #'API - assembly' }
AcAsmFormatLiteralTextChunk >> assembler [
	^self text asParser flatten  ==> [ :token | #() ]

]

{ #category : #'API - disassembly' }
AcAsmFormatLiteralTextChunk >> disassembleTo: aWriteStream operands: ops inEnvironment: e [
	aWriteStream nextPutAll: text

]

{ #category : #testing }
AcAsmFormatLiteralTextChunk >> isTextChunk [
	^ true
]

{ #category : #accessing }
AcAsmFormatLiteralTextChunk >> mnemonicsInto: aSet [
	"See AcAsmFormat >> #mnemonicsInto:"

	^ aSet add: text
]

{ #category : #accessing }
AcAsmFormatLiteralTextChunk >> text [
	^ text
]

{ #category : #accessing }
AcAsmFormatLiteralTextChunk >> text:aString [
	text := aString.

]

{ #category : #'printing & storing' }
AcAsmFormatLiteralTextChunk >> unparseOn: aStream [
   aStream nextPutAll: text
]
