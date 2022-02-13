Class {
	#name : #IslaNamedCollectionParagraph,
	#superclass : #IslaParagraph,
	#instVars : [
		'name',
		'members'
	],
	#category : #Isla
}

{ #category : #grammar }
IslaNamedCollectionParagraph class >> keyword [
	self subclassResponsibility
]

{ #category : #'instance creation' }
IslaNamedCollectionParagraph class >> name: s members: strings [
	^self basicNew 
		name: s;
		members: strings;
		yourself
]

{ #category : #accessing }
IslaNamedCollectionParagraph >> members [
	^ members
]

{ #category : #accessing }
IslaNamedCollectionParagraph >> members: anObject [
	members := anObject
]

{ #category : #accessing }
IslaNamedCollectionParagraph >> name [
	^ name
]

{ #category : #accessing }
IslaNamedCollectionParagraph >> name: anObject [
	name := anObject
]
