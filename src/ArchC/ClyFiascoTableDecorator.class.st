Class {
	#name : #ClyFiascoTableDecorator,
	#superclass : #ClyMethodTableDecorator,
	#category : #'ArchC-DUI'
}

{ #category : #testing }
ClyFiascoTableDecorator class >> decorateMainTableCell: anItemCellMorph of: aDataSourceItem [
	super decorateMainTableCell: anItemCellMorph of: aDataSourceItem.
	anItemCellMorph definitionIcon: #thumbsDown
]

{ #category : #testing }
ClyFiascoTableDecorator class >> decorateTableCell: anItemCellMorph of: aDataSourceItem [
]

{ #category : #testing }
ClyFiascoTableDecorator class >> wantsDecorateTableCellOf: aDataSourceItem [
	^aDataSourceItem isMarkedWith: ClyFiascoTag
]
