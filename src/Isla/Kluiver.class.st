Class {
	#name : #Kluiver,
	#superclass : #Object,
	#instVars : [
		'funs',
		'funTypes',
		'registers',
		'structs',
		'unions',
		'lets',
		'sourceFiles',
		'enums',
		'funDescriptions'
	],
	#category : #Isla
}

{ #category : #accessing }
Kluiver >> enums [
	^ enums
]

{ #category : #accessing }
Kluiver >> funDescriptions [
	^ funDescriptions 
]

{ #category : #accessing }
Kluiver >> funTypes [
	^ funTypes
]

{ #category : #accessing }
Kluiver >> funs [
	^ funs
]

{ #category : #GT }
Kluiver >> gtInspectorFunctionsIn: composite [
	<gtInspectorPresentationOrder: 2>
	^ composite fastTable
		title: 'Functions';
		display: [ funs associations ];
		column: 'Name' evaluated: [ :each | each key ];
		column: 'Args'	 evaluated: [ :each |
				| s |
				s := WriteStream on: String new.
				each value args do: [ :arg| s nextPutAll: arg ] separatedBy: [ s nextPutAll: ',' ].
				s contents ];
		column: 'Type' evaluated: [ :each |
			| t s |
			s := WriteStream on: String new.
			t := funTypes at: each name.
			t key do: [ :argType | argType printOn: s ] separatedBy: [ s nextPutAll: '×' ].
			s nextPutAll: ' → ', t value printString.
			s contents ];
		selectionAct: [ :table | 
			table rawSelection do: [ :assoc | self removeKey: assoc key ].
			table update
			]
			entitled: 'Remove item(s)';
		selectionPopulate: #selection
			entitled: 'Open key'
			with: [ :table | ( table rawSelection collect: #key ) gtInspectorInterestingObject ];
		beMultiple;
		send: [ :selection | 
			"withSmalltalkSearch;
		showOnly: 50;
		helpMessage: 'Quick selection field. Given your INPUT, it executes: self select: [:each | INPUT ]'"
			selection
				ifNil: [ nil ]
				ifNotNil: [ selection size = 1
						ifTrue: [ selection anyOne value ]
						ifFalse: [ selection collect: #value ]
					]
			]
]

{ #category : #GT }
Kluiver >> gtInspectorRegistersIn: composite [
	<gtInspectorPresentationOrder: 1>
	^ composite fastTable
		title: 'Registers';
		display: [ registers associations ];
			column: 'Name' evaluated: [ :each |
				each key first = $z ifFalse: [ self error ].
				each key allButFirst ];
		column: 'Type' evaluated: [ :each | GTObjectPrinter asTruncatedTextFrom: each value ];
		selectionAct: [ :table | 
			table rawSelection do: [ :assoc | self removeKey: assoc key ].
			table update
			]
			entitled: 'Remove item(s)';
		selectionPopulate: #selection
			entitled: 'Open key'
			with: [ :table | ( table rawSelection collect: #key ) gtInspectorInterestingObject ];
		beMultiple;
		send: [ :selection | 
			"withSmalltalkSearch;
		showOnly: 50;
		helpMessage: 'Quick selection field. Given your INPUT, it executes: self select: [:each | INPUT ]'"
			selection
				ifNil: [ nil ]
				ifNotNil: [ selection size = 1
						ifTrue: [ selection anyOne value ]
						ifFalse: [ selection collect: #value ]
					]
			]
]

{ #category : #initialization }
Kluiver >> initialize [ 
	funs := Dictionary new.
	funTypes := Dictionary new.
	funDescriptions := Dictionary new.
	lets := Dictionary new.
	registers := Dictionary new.
	structs := Dictionary new.
	unions := Dictionary new.
	enums := Dictionary new.

]

{ #category : #accessing }
Kluiver >> lets [
	^ lets
]

{ #category : #accessing }
Kluiver >> registers [
	^ registers
]

{ #category : #compilation }
Kluiver >> resolve: sort named: name [
	| sel dict |
	sort first = $% ifFalse: [ self error ].
	sel := sort allButFirst, 's'.
	dict := self perform: sel asSymbol.
	^dict at: name
]

{ #category : #accessing }
Kluiver >> sourceFiles [
	^ sourceFiles
]

{ #category : #accessing }
Kluiver >> sourceFiles: anObject [
	sourceFiles := anObject
]

{ #category : #accessing }
Kluiver >> structs [
	^ structs
]

{ #category : #accessing }
Kluiver >> unions [
	^ unions
]
