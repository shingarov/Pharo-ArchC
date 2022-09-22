"
I parse the ""printf-like format"" part of the ""instruction syntax variant"".
For example,

""lis %reg, %exp(carry)@ha"", rt, ra=0, d

is one assembly syntax variant for the addis instruction on PowerPC;
the format part in this example is

lis %reg, %exp(carry)@ha

As I am a Parser, my API is #parse:.
I answer a sequence of `AcAsmFormatChunk`s as the result.

"
Class {
	#name : #AcAsmFormatParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'token',
		'special',
		'space',
		'map',
		'builtin',
		'modifier',
		'operand',
		'mnemonic',
		'operands',
		'format'
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
AcAsmFormatParser >> builtin [
	| builtins |

	builtins := (AcAsmFormatBuiltinChunk builtins collect: [:e | e asParser ]) asChoiceParser.

	^ builtins , modifier optional
		==> [:nodes | 
			| builtinName  modifierClass |

			builtinName := nodes first.
			modifierClass := nodes second ifNil: [ NoOperandModifier ].
			AcAsmFormatChunk builtin: builtinName modifier: modifierClass
		]
]

{ #category : #grammar }
AcAsmFormatParser >> format [
	^ (mnemonic , (#space asParser plus , operands) optional) 
		==> [ :nodes| 
			| operands |

			nodes second notNil ifTrue: [ 
				operands := nodes second second.
			] ifFalse: [ 
				operands := AcAsmFormatChunk operands: #().
			].
			AcAsmFormat new mnemonic: nodes first; operands: operands
			]

]

{ #category : #grammar }
AcAsmFormatParser >> map [
	^( ($% asParser ,   #letter asParser plus flatten ) /
	   ('%[' asParser , #letter asParser plus flatten , ']' asParser) )
	   ==> [ :nodes | AcAsmFormatChunk map: nodes second ]

]

{ #category : #grammar }
AcAsmFormatParser >> mnemonic [
	| first rest |

	first := #letter asParser / $_ asParser.
	rest  := #letter asParser / #digit asParser / $_ asParser / $. asParser / $, asParser / '\%' asParser.

	^(((first , rest star) flatten ==> [ :token | AcAsmFormatChunk text: (self unescape: token) ])
	  , (map / (rest plus flatten  ==> [ :token | AcAsmFormatChunk text: (self unescape: token) ])) star)
	  ==> [ :nodes | AcAsmFormatChunk mnemonic: (Array with: nodes first) , nodes second]

]

{ #category : #grammar }
AcAsmFormatParser >> modifier [
	^$( asParser, #letter asParser , (#letter asParser / #digit asParser) star flatten, $) asParser ==> [ :x |
		| modifierName |
		modifierName := x second asString , x third.
		modifierName asUppercase asSymbol asClassIfAbsent: [ self error: 'Unknown operand modifier ', modifierName ] ]

]

{ #category : #grammar }
AcAsmFormatParser >> operand [
	^ (builtin / map / token / special / space) star
	==> [ :nodes | AcAsmFormatChunk sequence: nodes ]

]

{ #category : #grammar }
AcAsmFormatParser >> operands [
	^ operand , ($, asParser , operand) star
	==> [ :nodes |
		| operandNodes |

		operandNodes := { nodes first } , (nodes second collect: #second).
		AcAsmFormatChunk operands: operandNodes.
	].

]

{ #category : #grammar }
AcAsmFormatParser >> space [
   ^ #space asParser plus flatten
   ==> [ :token | AcAsmFormatChunk space: token ]

]

{ #category : #grammar }
AcAsmFormatParser >> special [
	^('\%' asParser
	/ (PPPredicateObjectParser anyExceptAnyOf: ' ,\%";')) flatten
	==> [ :token | AcAsmFormatChunk text: (self unescape: token) ]

]

{ #category : #grammar }
AcAsmFormatParser >> start [
	^ format end

]

{ #category : #grammar }
AcAsmFormatParser >> token [
   "a-zA-Z 0-9 $."
   ^ (#letter asParser / #digit asParser / $_ asParser / $. asParser / $$ asParser) flatten
   ==> [ :token | AcAsmFormatChunk text: token ]

]

{ #category : #utilities }
AcAsmFormatParser >> unescape: aString [
	"Replace escape-sequences from `aString` by their respective characters.
	 Currently only supports '\%'."

	(aString indexOf: $\) == 0 ifTrue: [ ^ aString ].
	^ String streamContents: [ :out |
		| in |

		in := aString readStream.
		[ in atEnd ] whileFalse: [ 
			| c |

			c := in next.
			c == $\ ifTrue:[
				c := in next.
				c ~~ $% ifTrue: [ self error: 'Unsupported escape sequence' ]
			].
			out nextPut: c.
		].
	].

]
