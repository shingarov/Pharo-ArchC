Class {
	#name : #AcSemanticTermParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'term',
		'functor',
		'arg',
		'operand',
		'imm',
		'const'
	],
	#category : #'ArchC-Parsing'
}

{ #category : #grammar }
AcSemanticTermParser >> arg [
	^ term / operand / imm / const
]

{ #category : #grammar }
AcSemanticTermParser >> const [
	^ 'const' asParser 
]

{ #category : #grammar }
AcSemanticTermParser >> functor [
	^ (#word asParser /
	(PPPredicateObjectParser chars: '.?!;:#$%&*+-/<>=@[]\^_{}|~' message:'functor'))
	star flatten
]

{ #category : #grammar }
AcSemanticTermParser >> imm [
	^ 'imm:Op' asParser,
	#hex asParser,
	':tgtimm' asParser ==> [ :x |
		ImmediateSemanticOperand new 
			number: ((String with: x second) asInteger);
			yourself ]
]

{ #category : #grammar }
AcSemanticTermParser >> operand [
	^ 'Op' asParser,
	#hex asParser,
	$: asParser,
	#uppercase asParser star flatten ==> [ :x |
		RegisterSemanticOperand new 
			number: ((String with: x second) asInteger);
			type: x fourth;
			yourself ]
]

{ #category : #grammar }
AcSemanticTermParser >> start [
	^term
]

{ #category : #grammar }
AcSemanticTermParser >> term [
	^ $( asParser trim,
	functor trim,
	arg trim star,
	$) asParser trim ==> [ :x |
		SemanticTerm new
			functor: x second;
			args: x third;
			yourself ]
]
