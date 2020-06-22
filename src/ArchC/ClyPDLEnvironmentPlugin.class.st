Class {
	#name : #ClyPDLEnvironmentPlugin,
	#superclass : #ClySystemEnvironmentPlugin,
	#category : #'ArchC-DUI'
}

{ #category : #testing }
ClyPDLEnvironmentPlugin class >> isAutoActivated [ 
	^true

]

{ #category : #testing }
ClyPDLEnvironmentPlugin class >> toActivateMe [
	"
	ClyNavigationEnvironment reset
	"

]

{ #category : #'groups collecting' }
ClyPDLEnvironmentPlugin >> collectMethodGroupProviders [ 
	^AcProcessorDescriptions knownISAs collect: [ :aSymbol |
		ClyASMMethodGroupProvider isa: aSymbol ]
	
]

{ #category : #'item decoration' }
ClyPDLEnvironmentPlugin >> decorateBrowserItem: anItem ofMethod: aMethod [
	aMethod isASMMethod ifTrue: [ 
		anItem markWith: ClyASMMethodTag]
]
