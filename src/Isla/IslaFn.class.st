Class {
	#name : #IslaFn,
	#superclass : #IslaNamedCollectionParagraph,
	#instVars : [
		'args'
	],
	#category : #Isla
}

{ #category : #grammar }
IslaFn class >> keyword [
	^'fn'
]

{ #category : #'instance creation' }
IslaFn class >> name: n args: aa members: mm [
	^(self name: n members: mm)
		args: aa; yourself
]

{ #category : #accessing }
IslaFn >> allSourceFiles [
	| ff |
	ff := (members collect: #sourceFile) asSet.
	ff remove: nil ifAbsent: [].
	^ff
]

{ #category : #compilation }
IslaFn >> analyzeContextFor: aKluiver [ 
	aKluiver funs at: name put: self.
	program := aKluiver.
	(program funTypes includesKey: name) ifFalse: [ self error ]
]

{ #category : #accessing }
IslaFn >> args [
	^ args
]

{ #category : #accessing }
IslaFn >> args: anObject [
	args := anObject
]

{ #category : #GT }
IslaFn >> gtInspectorIrIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite fastTable
		title: 'IR';
		display: [ members ];
		beMultiple;
		enableElementIndex;
		wantsAutomaticRefresh: true;
		column: 'Index' evaluated: [ :value :idex | idex asString ] width: 50;
		column: 'Statement' evaluated: [ :value | GTObjectPrinter asTruncatedTextFrom: value ];
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

{ #category : #GT }
IslaFn >> gtInspectorPresentationsFromPragmas: pragmas In: composite inContext: aGTInspector [
	super gtInspectorPresentationsFromPragmas: pragmas In: composite inContext: aGTInspector.
	self gtInspectorSourcePresentationsIn: composite
]

{ #category : #GT }
IslaFn >> gtInspectorSourcePresentationOf: aSourceFile in: composite [
	composite text
			title: aSourceFile basename;
			format: #asText;
			display: [ aSourceFile readStream contents ];
			withLineNumbers: true;
			act: [ :text | self ensureDelete; writeStreamDo: [ :s | s nextPutAll: text text asString ] ]
				icon: GLMUIThemeExtraIcons glamorousSave
				on: $s
				entitled: 'Save'
]

{ #category : #GT }
IslaFn >> gtInspectorSourcePresentationsIn: composite [
		self allSourceFiles do: [ :aSourceFile |
			self gtInspectorSourcePresentationOf: aSourceFile in: composite ]
]
