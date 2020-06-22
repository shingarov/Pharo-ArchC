"
I parse the ""printf-like format"" part of the ""instruction syntax variant"".
For example,

""lis %reg, %exp(carry)@ha"", rt, ra=0, d

is one assembly syntax variant for the addis instruction on PowerPC;
the format part in this example is

lis %reg, %exp(carry)@ha

As I am a Parser, my API is #parse:.
I answer a sequence of AcMnemonicChunks as the result.


"
Class {
	#name : #AcMnemonicFormatParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'percentId',
		'normal',
		'escape',
		'modifier'
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
	^percentIdString asParser, modifier optional  ==> [ :immTokens |
		| imm modifierClass |
		imm := immTokens first.
		modifierClass := immTokens second ifNil: [ NoOperandModifier ].
		BuiltinOperandChunk type: imm modifier: modifierClass ]
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
AcMnemonicFormatParser >> modifier [
	^$( asParser, #letter asParser star flatten, $) asParser ==> [ :x |
		| modifierName |
		modifierName := x second.
		modifierName asUppercase asClassIfAbsent: [ self error: 'Unknown operand modifier ', modifierName ] ]
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
