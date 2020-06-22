Class {
	#name : #ClyASMMethodTableDecorator,
	#superclass : #ClyMethodTableDecorator,
	#category : #'ArchC-DUI'
}

{ #category : #decoration }
ClyASMMethodTableDecorator class >> decorateMainTableCell: anItemCellMorph of: aDataSourceItem [
	super decorateMainTableCell: anItemCellMorph of: aDataSourceItem.
	anItemCellMorph definitionIcon: #tools
]

{ #category : #decoration }
ClyASMMethodTableDecorator class >> decorateTableCell: anItemCellMorph of: aDataSourceItem [
]

{ #category : #testing }
ClyASMMethodTableDecorator class >> wantsDecorateTableCellOf: aDataSourceItem [
	^aDataSourceItem isMarkedWith: ClyASMMethodTag
]
