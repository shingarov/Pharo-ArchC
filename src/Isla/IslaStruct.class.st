Class {
	#name : #IslaStruct,
	#superclass : #IslaNamedCollectionParagraph,
	#category : #Isla
}

{ #category : #grammar }
IslaStruct class >> keyword [
	^'struct'
]

{ #category : #compiling }
IslaStruct >> analyzeContextFor: aKluiver [
	members := Dictionary newFromAssociations: members.
	aKluiver structs at: name put: self
]

{ #category : #GT }
IslaStruct >> gtInspectorMembersIn: composite [
	<gtInspectorPresentationOrder: 1>
	^ composite fastTable
		title: 'Members';
		display: [ members associations ];
			column: 'Name' evaluated: [ :each |
				"each key first = $z ifFalse: [ self error ].
				each key allButFirst" '???' ];
		column: 'Type' evaluated: [ :each | GTObjectPrinter asTruncatedTextFrom: "each value" '???' ];
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

{ #category : #printing }
IslaStruct >> printOn: aStream [
	aStream nextPutAll: '%struct '.
	aStream nextPutAll: name
]
