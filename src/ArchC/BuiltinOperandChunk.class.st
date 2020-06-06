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
	^self immLiteral / self immExpression 
]

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> disassembleTo: aWriteStream inEnvironment: anOrderedCollection [
	aWriteStream nextPutAll: '0x'.
	anOrderedCollection removeFirst printOn: aWriteStream base: 16 showRadix: false
]

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> immExpression [
	^${ asParser, ($} asParser not, #any asParser) star flatten, $} asParser ==> [ :expr | expr second "the string inside {...} will become the variable name" ]
]

{ #category : #'API - disassembly' }
BuiltinOperandChunk >> immLiteral [
	^#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ]
]
