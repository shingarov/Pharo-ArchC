Class {
	#name : #KluiverParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'paragraph',
		'enum',
		'files',
		'fn',
		'register',
		'struct',
		'union',
		'val',
		'id',
		'enumMember',
		'type',
		'functionType',
		'expression',
		'let'
	],
	#category : #Isla
}

{ #category : #parsing }
KluiverParser class >> parseProgram: program [
	| paragraphs result |
	paragraphs := (String with: Character lf with: Character lf) split: program.
	paragraphs := paragraphs reject: #isEmpty.

	result := ContextFreeKluiver paragraphs: OrderedCollection new.
	paragraphs do: [ :p |
		| paragraph |
		paragraph := self parse: p.
		result paragraphs addLast: paragraph.
		paragraph program: result ] displayingProgress: [ :each | each lines first ].
	^result
	

]

{ #category : #'grammar-expressions' }
KluiverParser >> application [
	"f(x, y)"
	^id,
	$( asParser,
	((expression separatedBy: ', ' asParser) ==> [:seq| seq reject: [:tok|tok=', ']]),
	$) asParser
	==> [ :x | IsExApplication functor: x first args: x third ]
]

{ #category : #'grammar-statements' }
KluiverParser >> arbitraryStatement [
	^ 'arbitrary' asParser
	==> [ :x | I_undefined new ]
]

{ #category : #'grammar-expressions' }
KluiverParser >> as [
	^ self projection
	, ' as ' asParser
	, self projection
	==> [ :x | #AS ]
]

{ #category : #'grammar-statements' }
KluiverParser >> assignmentStatement [
	^ self projection
	, $* asParser optional
	, ' = ' asParser
	, expression
	==> [ :x | JibSSA name: x first expression: x last ]
]

{ #category : #grammar }
KluiverParser >> binaryNumber [
	^ '0b' asParser, ('0' asParser / '1' asParser) plus flatten
		==> [ :x | Integer readFrom: x second base: 2 ]
]

{ #category : #grammar }
KluiverParser >> decimalNumber [
	^ ($- asParser optional, #digit asParser plus) flatten
		==> [ :x | x asInteger ]
]

{ #category : #'grammar-statements' }
KluiverParser >> declarationStatement [
	^id, ' : ' asParser, type
	==> [ :x | JibTypeDeclaration name: x first type: x last ]
]

{ #category : #'grammar-statements' }
KluiverParser >> endStatement [
	^ 'end' asParser
	==> [ :x | JibEnd new ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> enum [
	^self
		structure: IslaEnum
		of: self enumMember
		separatedBy: $, asParser, self lineFeed
]

{ #category : #grammar }
KluiverParser >> enumMember [
	^self indent, id ==> [ :line | line second ]
]

{ #category : #'grammar-expressions' }
KluiverParser >> expression [
	^ self literal
	/ self as
	/ self application
	/ self projection
	/ self ref

]

{ #category : #'grammar-statements' }
KluiverParser >> failureStatement [
	^ 'failure' asParser
	==> [ :x | JibFailure new ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> files [ 
	^'files ' asParser,
	(self quotedString separatedBy: (#space asParser plus ==> [:__|#separator]))
	==> [ :x | IslaFiles files: (x second reject: [:tok|tok==#separator]) ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> fn [
	^ IslaFn keyword asParser trim, self fnHead trim, '{' asParser, self lineFeed,
	(self statement delimitedBy: ';' asParser, self lineFeed ==> [:sep|#separator]),
	$} asParser
	==> [ :x |
		| n aa statements f |
		n := x second key.
		aa := x second value.
		statements := x fifth reject: [:tok|tok==#separator].
		f := IslaFn name: n args: aa members: statements.
		statements do: [ :stmt | stmt parent: f ].
		f
	]
]

{ #category : #grammar }
KluiverParser >> fnHead [
	^ id, '(' asParser,
	(id separatedBy: ', ' asParser ==> [:sep|#separator]),
	')' asParser
	==> [ :x | x first ->
		(x third reject: [:tok|tok==#separator]) ]
]

{ #category : #'grammar-types' }
KluiverParser >> functionType [
	^ $( asParser,
	(type separatedBy: ',' asParser trim ==> [:comma|#separator]),
	$) asParser trim,
	'->' asParser trim,
	self type asParser ==> [ :x | (x second reject: [:tok| tok==#separator]) -> x last ]
]

{ #category : #'grammar-statements' }
KluiverParser >> gotoStatement [
	^'goto ' asParser, self decimalNumber
	==> [ :x | JibGoto to: x second ]
]

{ #category : #grammar }
KluiverParser >> hexNumber [
	^ '0x' asParser, #word asParser plus flatten
		==> [ :x | Integer readFrom: x second base: 16 ]
]

{ #category : #grammar }
KluiverParser >> id [
	^(
	#letter asParser / $_ asParser / $$ asParser / $@ asParser,
	(#word  asParser / $_ asParser / $$ asParser / $@ asParser) star
	) flatten
]

{ #category : #grammar }
KluiverParser >> indent [
	^Character space asParser plus
]

{ #category : #'grammar-statements' }
KluiverParser >> jumpCondition [
	^ ( self projection
	  , ' is ' asParser
	  , id
	  ==> [ :x | IsExIs l: x first r: x last ]
	  )
	/ expression

]

{ #category : #'grammar-statements' }
KluiverParser >> jumpStatement [
	^'jump ' asParser,
	self jumpCondition,
	' goto ' asParser,
	self decimalNumber
	==> [ :x | (JibJump to: x fourth) condition: x second; yourself  ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> let [
	^ 'let (' asParser
	, id
	, ': ' asParser
	, type
	, ') {' asParser, self lineFeed
	, (self statement delimitedBy: ';' asParser, self lineFeed ==> [:sep|#separator])
	, '}' asParser
	==> [ :x | (CDEF_let name: x second members: (x seventh reject: [:tok|tok==#separator])) type: x fourth; yourself ]
]

{ #category : #grammar }
KluiverParser >> lineFeed [
	^Character cr asParser / Character lf asParser
]

{ #category : #'grammar-expressions' }
KluiverParser >> literal [
	^ self unit
	/ self binaryNumber
	/ self hexNumber
	/ self decimalNumber
	/ self quotedString
	==> [ :value | IsExLiteral literal: value ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> paragraph [
	^ enum
	/ files
	/ fn
	/ let
	/ register
	/ struct
	/ union
	/ val
]

{ #category : #'grammar-expressions' }
KluiverParser >> projection [
	^(id separatedBy: $. asParser)
	==> [ :x | IsExVar segments: (x reject: [ :tok| tok==$. ]) ]
]

{ #category : #grammar }
KluiverParser >> quotedString [
	^ $" asParser 
	, (PPPredicateObjectParser anyExceptAnyOf: '"') star flatten
	, $" asParser
	==> [ :f | f second ]
]

{ #category : #'grammar-expressions' }
KluiverParser >> ref [
	^ $& asParser
	, self projection
	==> [ :x | #REF ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> register [
	^ 'register ' asParser
	, id
	, ' : ' asParser
	, type
	==> [ :x | IslaRegister name: x second type: x fourth ]
]

{ #category : #'grammar-statements' }
KluiverParser >> sourceReference [
	^ ' ``' asParser ==> [:x|nil]
	/ (
		(' `' asParser, #digit asParser plus flatten ==> [:x|x second asInteger]),
		$  asParser,
		(#digit asParser plus flatten ==> [:x|x asInteger]),
		$: asParser,
		(#digit asParser plus flatten ==> [:x|x asInteger]),
		$- asParser,
		(#digit asParser plus flatten ==> [:x|x asInteger]),
		$: asParser,
		(#digit asParser plus flatten ==> [:x|x asInteger])
	==> [ :x | JibSourceReference
		fileIndex: x first
		from: x fifth @ x third
		to: x ninth @ x seventh ]
	)
	
]

{ #category : #grammar }
KluiverParser >> start [
	^paragraph end
]

{ #category : #'grammar-statements' }
KluiverParser >> statement [
	^ self indent, (
		self endStatement
	/ self failureStatement
	/ self arbitraryStatement
	/ self gotoStatement
	/ self jumpStatement
	/ self declarationStatement
	/ self assignmentStatement
	),
	self sourceReference optional
	==> [ :x |
		| stmt src |
		stmt := x second.
		src := x third.
		src isNil ifFalse: [ stmt sourceReference: src.  src statement: stmt ].
		stmt ]
	
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> struct [
	^self
		structure: IslaStruct
		of: self unionMember
		separatedBy: $, asParser, self lineFeed
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> structure: class of: memberParser separatedBy: separator [
	^ class keyword asParser trim, id trim, ${ asParser, self lineFeed,
	(memberParser separatedBy: separator ==> [:sep|#separator]),
	self lineFeed, $} asParser
	==> [ :x | class name: x second members: (x fifth reject: [:tok|tok==#separator]) ]
]

{ #category : #'grammar-types' }
KluiverParser >> type [
	^ self typeBVn
	/ self typeBit
	/ self typeBool
	/ self typeEnum
	/ self typeFVec
	/ self typeI
	/ self typeList
	/ self typeReal
	/ self typeRef
	/ self typeString
	/ self typeStruct
	/ self typeUnion
	/ self typeUnit
	/ self typeVec

]

{ #category : #'grammar-types' }
KluiverParser >> typeBVn [
	^ '%bv' asParser, #digit asParser plus flatten optional
	==> [ :x |
		| length |
		length := x second.
		length ifNil: [ #BV "BOGUS" ] ifNotNil: [BitVector /// length asInteger]
	]
]

{ #category : #'grammar-types' }
KluiverParser >> typeBit [
	^ '%bit' asParser ==> [ :x | #BIT "BOGUS" ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeBool [
	^ '%bool' asParser ==> [ :x | Bool sort ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeEnum [
	^ '%enum' asParser trim, id ==> [ :x | IslaReferenceCell sort: x first id: x second ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeFVec [
	^ '%fvec(' asParser
	, self decimalNumber
	, ', ' asParser
	, type
	, ')' asParser
	==> [ :x | (CT_fvector elementType: x fourth) n: x second; yourself ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeI [
	^ '%i' asParser, #digit asParser plus flatten optional
	==> [ :x |
		| length |
		length := x second.
		length ifNil: [Int sort] ifNotNil: [#IXX "BOGUS"]		
	]
]

{ #category : #'grammar-types' }
KluiverParser >> typeList [
	^ '%list(' asParser, type, ')' asParser ==> [ :x | IslaList elementType: x second ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeReal [
	^ '%real' asParser ==> [ :x | Real sort ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeRef [
	^ '&(' asParser,
	type,
	$) asParser
	==> [ :x | CT_ref elementType: x second ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeString [
	^ '%string' asParser ==> [ :x | String "BOGUS, should be a Z3 String sort" ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeStruct [
	^ '%struct' asParser trim, id ==> [ :x | IslaReferenceCell sort: x first id: x second ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeUnion [
	^ '%union' asParser trim, id ==> [ :x | IslaReferenceCell sort: x first id: x second ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeUnit [
	^ '%unit' asParser ==> [ :__ | UndefinedObject ]
]

{ #category : #'grammar-types' }
KluiverParser >> typeVec [
	^ '%vec(' asParser, type, ')' asParser ==> [ :x | IslaVec elementType: x second ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> union [
	^self
		structure: IslaUnion
		of: self unionMember
		separatedBy: $, asParser, self lineFeed
]

{ #category : #grammar }
KluiverParser >> unionMember [
	^self indent, id, ': ' asParser, type ==> [ :line | line second -> line fourth ]
]

{ #category : #'grammar-expressions' }
KluiverParser >> unit [
	^ '()' asParser
	==> [ :__ | nil ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> val [
	^'val' asParser trim,
	id trim,
	self valDescription optional trim,
	$: asParser trim,
	functionType
	==> [ :x | IslaVal
		name: x second 
		description: x third 
		type: x fifth ]
]

{ #category : #'grammar-paragraphs' }
KluiverParser >> valDescription [
	^$= asParser trim,
	$" asParser,
	(PPPredicateObjectParser
		on: (PPCharSetPredicate on: [ :ch | ch ~~ $" ])
		message: 'Token expected') plus flatten,
	$" asParser
	==> [ :x | x third ]
]
