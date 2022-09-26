Class {
	#name : #AcDefinesParser,
	#superclass : #AcCommonParser,
	#instVars : [
		'defineDirectives',
		'defineDirective'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #'as yet unclassified' }
AcDefinesParser >> defineDirective [
	^'#define' asParser trim,
	id trim,
	self class newline negate star flatten,
	self class newline
	==> [ :x | x second -> x third ]

]

{ #category : #'as yet unclassified' }
AcDefinesParser >> defineDirectives [
	^defineDirective star
	==> [ :x | 
		| defines | 

		defines := Dictionary new.
		x do: [ :e | defines add: e ].
		defines
		]
]

{ #category : #'as yet unclassified' }
AcDefinesParser >> start [
	^defineDirectives
		==> [ :x | x ]
]
