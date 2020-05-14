Class {
	#name : #AcMnemonicFormatParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'percentId',
		'normal',
		'escape'
	],
	#classInstVars : [
		'maps'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #parsing }
AcMnemonicFormatParser class >> maps [
	^maps
]

{ #category : #'instance creation' }
AcMnemonicFormatParser class >> maps: m [
	"The argument here is the final result of parsing
	the ac_asm_map statements in *_isa.ac.
	"
	"TODO -- EXTREMELY BAD.
	I am not sure how to parametrize a parser when productions depend on the parametrization."
	maps := m.
	^ self new
]

{ #category : #grammar }
AcMnemonicFormatParser >> allOperandTypes [
	^self builtinOperandTypes, self userOperandTypes 
]

{ #category : #grammar }
AcMnemonicFormatParser >> builtinOperandType: percentIdString [
	^percentIdString asParser ==> [ :immToken |
		BuiltinOperandChunk new ]
]

{ #category : #grammar }
AcMnemonicFormatParser >> builtinOperandTypes [
	^#('%imm' '%exp' '%addr') collect: [ :s | self builtinOperandType: s ]
]

{ #category : #grammar }
AcMnemonicFormatParser >> escape [
	^'\%' asParser ==> [ :x | LiteralTextChunk char: $% ]

]

{ #category : #grammar }
AcMnemonicFormatParser >> normal [
	^(PPPredicateObjectParser anyExceptAnyOf: '%\"') ==> [ :char |
		LiteralTextChunk char: char ]
]

{ #category : #grammar }
AcMnemonicFormatParser >> percentId [
	^PPChoiceParser withAll: self allOperandTypes 
]

{ #category : #grammar }
AcMnemonicFormatParser >> start [
	"The result of parsing a format string is a 1-argument block which,
	 given an ordered collection of operand values,
	 answers a string of disassembly."
	^ (normal / escape / percentId) star end
]

{ #category : #grammar }
AcMnemonicFormatParser >> userOperandTypeName: mapName mapping: aDictionary [
	^('%', mapName) asParser / ('%[', mapName, ']') asParser ==> [ :token |
		(PercentAcMnemonicChunk map: aDictionary named: mapName source: token) ]
]

{ #category : #grammar }
AcMnemonicFormatParser >> userOperandTypes [
	^self class maps associations collect: [ :a |
		self userOperandTypeName: a key mapping: a value ]
]
