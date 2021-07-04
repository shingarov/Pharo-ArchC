"
I parse PowerISA pseudocode notation, as defined in PowerISA spec version 3.0B, p.4 et seq.
"
Class {
	#name : #MdwnPseudocodeParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'gprName',
		'number',
		'hexNumber',
		'binaryNumber',
		'decimalNumber',
		'fprName',
		'raOr0'
	],
	#category : #'ArchC-LibreSOC'
}

{ #category : #'grammar-numbers' }
MdwnPseudocodeParser >> binaryNumber [
	"0bnnnn means a number expressed in binary format."
	^'0b' asParser, ($0 asParser / $1 asParser / $_ asParser) plus
		==> [ :prefix_digits |
				| digits |
				digits := prefix_digits second reject: [ :char | char = $_ ].
				Integer readFrom: (String withAll: digits) base: 2 ]
]

{ #category : #'grammar-numbers' }
MdwnPseudocodeParser >> decimalNumber [
	^(#digit asParser / $_ asParser) plus 
		==> [ :digits |
				Integer readFrom: (String withAll: (digits reject: [ :char | char = $_ ])) ]
]

{ #category : #grammar }
MdwnPseudocodeParser >> exts [
	"EXTS(x)
		Result of extending x on the left with sign bits"
	^'EXTS' shouldBeImplemented 
]

{ #category : #'grammar-registers' }
MdwnPseudocodeParser >> fprName [
	"FRT, FRA, FR1,... refer to Floating-Point Registers."
	^PPChoiceParser withAll: (self fprNames collect: #asParser)
]

{ #category : #'grammar-registers' }
MdwnPseudocodeParser >> fprNames [
	^#('FRA' 'FRB' 'RS' 'RT')
]

{ #category : #'grammar-registers' }
MdwnPseudocodeParser >> gprName [
	"RT, RA, R1,... refer to General Purpose Registers."
	^PPChoiceParser withAll: (self gprNames collect: #asParser)
]

{ #category : #'grammar-registers' }
MdwnPseudocodeParser >> gprNames [
	^#('RA' 'RB' 'RC' 'RS' 'RT')
]

{ #category : #'grammar-numbers' }
MdwnPseudocodeParser >> hexNumber [
	"0xnnnn means a number expressed in hexadecimal format."
	^'0x' asParser, (#hex asParser / $_ asParser) plus
		==> [ :prefix_digits |
				| digits |
				digits := prefix_digits second reject: [ :char | char = $_ ].
				Integer readFrom: (String withAll: digits) base: 16 ]
]

{ #category : #grammar }
MdwnPseudocodeParser >> mask [
	"MASK(x,y)
		Mask having 1s in positions x through y
		(wrapping if x> y) and 0s elsewhere"
	^'MASK' shouldBeImplemented 
]

{ #category : #'grammar-numbers' }
MdwnPseudocodeParser >> number [
	"All numbers are decimal unless specified in some special way.
	Underscores may be used between digits."
	^hexNumber / binaryNumber / decimalNumber
]

{ #category : #grammar }
MdwnPseudocodeParser >> onesComplement [
	"¬(RA) means the one's complement of the contents of register RA."
	"In the real book, ¬ is used with many other kinds of expressions."
	^$¬ asParser, 'should be implemented' asParser
]

{ #category : #grammar }
MdwnPseudocodeParser >> rContents [
	"(x) means the contents of register x,
	where x is the name of an instruction field.
	For example, (RA) means the contents of register RA,
	and (FRA) means the contents of register FRA,
	where RA and FRA are instruction fields.
	Names such as LR and CTR denote registers, not fields,
	so parentheses are not used with them.
	Parentheses are also omitted when register x is the register
	into which the result of an operation is placed."
	^$( asParser, (gprName/fprName), $) asParser
		/ raOr0
]

{ #category : #'grammar-registers' }
MdwnPseudocodeParser >> raOr0 [
	"(RA|0) means the contents of register RA if the RA field
	has the value 1-31, or the value 0 if the RA field is 0."
	^'(RA|0)' asParser
]

{ #category : #grammar }
MdwnPseudocodeParser >> start [
	^number 
]
