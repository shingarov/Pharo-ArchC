Class {
	#name : #ClyASMMethodGroupProvider,
	#superclass : #ClySingleMethodGroupProvider,
	#instVars : [
		'isa'
	],
	#category : #'ArchC-DUI'
}

{ #category : #'instance creation' }
ClyASMMethodGroupProvider class >> isa: aSymbol [
	^self new
		isa: aSymbol;
		yourself
		
]

{ #category : #'building groups' }
ClyASMMethodGroupProvider >> createMethodGroupFor: aMethodQuery from: aClassScope [
	^ClyMethodGroup
		named: isa asString, ' assembler'
		on: aMethodQuery
]

{ #category : #'building groups' }
ClyASMMethodGroupProvider >> createMethodQueryFrom: aClassScope [
	^(ClyASMMethodQuery from: aClassScope)
		isa: isa;
		yourself 
]

{ #category : #accessing }
ClyASMMethodGroupProvider >> isa [
	^ isa
]

{ #category : #accessing }
ClyASMMethodGroupProvider >> isa: anObject [
	isa := anObject
]
