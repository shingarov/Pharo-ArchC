Class {
	#name : #BuiltinOperandChunk,
	#superclass : #AcMnemonicChunk,
	#instVars : [
		'char'
	],
	#category : #'ArchC-Core'
}

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> assembler [ 
	self flag: #TODO.
	^#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ]
]

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> disassembleTo: aWriteStream inEnvironment: anOrderedCollection [
	aWriteStream nextPutAll: '0x'.
	anOrderedCollection removeFirst printOn: aWriteStream base: 16 showRadix: false
]
