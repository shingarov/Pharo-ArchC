Class {
	#name : #AcMnemonicParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'format',
		'operand',
		'operandOrConstraint',
		'constraintConstant',
		'constraintMap',
		'operands',
		'id',
		'decimalNumber',
		'number',
		'hexNumber'
	],
	#classInstVars : [
		'maps'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #'instance creation' }
AcMnemonicParser class >> maps [
	^maps
]

{ #category : #'instance creation' }
AcMnemonicParser class >> maps: m [
	"TODO -- EXTREMELY BAD.
	I am not sure how to parametrize a parser when productions depend on the parametrization."
	"See also AcMnemonicFormatParser class, which gets the maps from me.
	I, in turn, get filled in #fillMnemonicsFrom: which comes from #fillMapsFrom:,
	which is executed on each ISA parse."
	maps := m.
	^ self new
]

{ #category : #grammar }
AcMnemonicParser >> constraintConstant [
	^id, $= asParser, number
	==> [  :x | AcMnemonicConstraintConstant new
			op: (x first);
			c: (x third);
			yourself ]
]

{ #category : #grammar }
AcMnemonicParser >> constraintMap [
	^id, $= asParser, id, '.map_to("' asParser, id, '")' asParser 
	==> [  :x | 
		| map |
		map := self class maps at: x third.
		AcMnemonicConstraintConstant  new
			op: (x first);
			c: (map keyAtValue: x fifth ifAbsent: [ self error ]);
			yourself ]
]

{ #category : #grammar }
AcMnemonicParser >> decimalNumber [
	^#digit asParser plus flatten ==> [ :x | x asInteger ]
]

{ #category : #grammar }
AcMnemonicParser >> format [
	^ ($" asParser,
	(( PPPredicateObjectParser anyExceptAnyOf: '"' ) star flatten ==> [ :x |
		(AcMnemonicFormatParser maps: self class maps) parse: x ]),
	$" asParser) ==> [ :f | f second ]
]

{ #category : #grammar }
AcMnemonicParser >> hexNumber [
	^'0x' asParser , #hex asParser star flatten ==> [ :x | Integer readFrom: x second base: 16 ]
]

{ #category : #grammar }
AcMnemonicParser >> id [
	^(#letter asParser, ($_ asParser / #word asParser) star) flatten
]

{ #category : #grammar }
AcMnemonicParser >> number [
	^ hexNumber / decimalNumber 
]

{ #category : #grammar }
AcMnemonicParser >> operand [
	^id, ($+ asParser, operand) optional
	==> [ :x | x last isNil
		ifTrue: [[ :env | env at: x first ]]
		ifFalse: [[ :env | (env at: x first) + ((x last last) value: env) ]]]
]

{ #category : #grammar }
AcMnemonicParser >> operandOrConstraint [
	^constraintConstant / constraintMap / operand
]

{ #category : #grammar }
AcMnemonicParser >> operands [
	^($, asParser trim, operandOrConstraint trim) star ==>
	[  :x | x collect: [ :op | op second  ]]
]

{ #category : #grammar }
AcMnemonicParser >> start [
	^$( asParser,
	format,
	operands,
	$) asParser ==>
	[  :x |
	AcMnemonicSpec
		format: (x second)
		operandsAndConstraints: (x third) ]
]
