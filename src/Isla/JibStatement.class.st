Class {
	#name : #JibStatement,
	#superclass : #Object,
	#instVars : [
		'sourceReference',
		'parent'
	],
	#category : #Isla
}

{ #category : #GT }
JibStatement >> gtInspectorSourceIn: composite [ 
	<gtInspectorPresentationOrder: 30>
	sourceReference isNil ifTrue: [ ^nil ].
	^ composite sailSource
		title: 'Sail Source';
		display: [ sourceReference text ];
		initialize: [ :presentation | 
			presentation selectionInterval: sourceReference sourceInterval ];
		act: [ self browse ]
			icon: GLMUIThemeExtraIcons glamorousBrowse
			entitled: 'Browse'
]

{ #category : #accessing }
JibStatement >> parent [
	^ parent
]

{ #category : #accessing }
JibStatement >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
JibStatement >> program [
	^ parent program
]

{ #category : #accessing }
JibStatement >> sourceFile [
	sourceReference isNil ifTrue: [ ^nil "damn we really miss monads" ].
	^ sourceReference fileReference 
]

{ #category : #accessing }
JibStatement >> sourceReference [
	^ sourceReference
]

{ #category : #accessing }
JibStatement >> sourceReference: anObject [
	sourceReference := anObject
]
