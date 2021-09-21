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
	#name : #AcAsmFormatParser,
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
	#category : #'ArchC-Core-Parsing'
}

{ #category : #parsing }
AcAsmFormatParser class >> maps [
	^maps
]

{ #category : #'instance creation' }
AcAsmFormatParser class >> maps: m [
	"The argument here is the final result of parsing
	the ac_asm_map statements in *_isa.ac.
	"
	"TODO -- EXTREMELY BAD.
	I am not sure how to parametrize a parser when productions depend on the parametrization."
	maps := m.
	^ self new
]

{ #category : #grammar }
AcAsmFormatParser >> allOperandTypes [
	^self builtinOperandTypes, self userOperandTypes 
]

{ #category : #grammar }
AcAsmFormatParser >> builtinOperandType: percentIdString [ 
	^ (percentIdString asParser , modifier optional) 
		==> [:immTokens | 
			| imm  modifierClass |

			imm := immTokens first.
			modifierClass := immTokens second ifNil: [ NoOperandModifier ].
			AcAsmFormatBuiltinChunk type: imm modifier: modifierClass
		]
]

{ #category : #grammar }
AcAsmFormatParser >> builtinOperandTypes [
	^#('%imm' '%exp' '%addr') collect: [ :s | self builtinOperandType: s ]
]

{ #category : #grammar }
AcAsmFormatParser >> escape [
	^ '\%' asParser ==> [:x | AcAsmFormatLiteralTextChunk char: $% ]
]

{ #category : #grammar }
AcAsmFormatParser >> modifier [
	^$( asParser, #letter asParser , (#letter asParser / #digit asParser) star flatten, $) asParser ==> [ :x |
		| modifierName |
		modifierName := x second asString , x third.
		modifierName asUppercase asSymbol asClassIfAbsent: [ self error: 'Unknown operand modifier ', modifierName ] ]

]

{ #category : #grammar }
AcAsmFormatParser >> normal [
	^ (PPPredicateObjectParser anyExceptAnyOf: '%\"') 
		==> [:char | AcAsmFormatLiteralTextChunk char: char ]
]

{ #category : #grammar }
AcAsmFormatParser >> percentId [
	^PPChoiceParser withAll: self allOperandTypes 
]

{ #category : #grammar }
AcAsmFormatParser >> start [
	"The result of parsing a format string is a 1-argument block which,
	 given an ordered collection of operand values,
	 answers a string of disassembly."
	^ (normal / escape / percentId) star end
]

{ #category : #grammar }
AcAsmFormatParser >> userOperandTypeName: mapName mapping: aDictionary [ 
	^ ('%' , mapName) asParser / ('%[' , mapName , ']') asParser 
		==> [:token | 
			(AcAsmFormatMapChunk 
				map: aDictionary
				named: mapName
				source: token)
		]
]

{ #category : #grammar }
AcAsmFormatParser >> userOperandTypes [
	^self class maps associations collect: [ :a |
		self userOperandTypeName: a key mapping: a value ]
]
