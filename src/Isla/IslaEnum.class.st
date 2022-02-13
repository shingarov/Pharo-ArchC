Class {
	#name : #IslaEnum,
	#superclass : #IslaNamedCollectionParagraph,
	#category : #Isla
}

{ #category : #grammar }
IslaEnum class >> keyword [
	^'enum'
]

{ #category : #compilation }
IslaEnum >> analyzeContextFor: aKluiver [ 
	aKluiver enums at: name put: self
]

{ #category : #GT }
IslaEnum >> gtInspectorItemsIn: composite [
	<gtInspectorPresentationOrder: 1>
	^ composite fastTable
		title: 'Members';
		display: [ members ];
		beMultiple;
		enableElementIndex;
		wantsAutomaticRefresh: true;
		column: 'Index' evaluated: [ :value :idex | idex asString ] width: 50;
		column: 'Item' evaluated: [ :value | GTObjectPrinter asTruncatedTextFrom: value ];
		send: [ :result | 
			"withSmalltalkSearch;
		showOnly: 50;
		helpMessage: 'Quick selection field. Given your INPUT, it executes: self select: [:each | INPUT ]'."
			result
				ifNil: [ nil ]
				ifNotNil: [ result size = 1
						ifTrue: [ result anyOne ]
						ifFalse: [ self species withAll: result ]
					]
			]
]

{ #category : #printing }
IslaEnum >> printOn: aStream [
	aStream nextPutAll: '%enum '.
	aStream nextPutAll: name
]
