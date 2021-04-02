Class {
	#name : #GtArchCSection,
	#superclass : #GtHomeSection,
	#category : #'ArchC-Docs'
}

{ #category : #accessing }
GtArchCSection >> create [
	| sectionContainer cardsContainer |
	sectionContainer := self newSectionContainer.
	sectionContainer addChild: (self newSectionTitle: 'Processor ISA Models').
	cardsContainer := self newCardsContainer.
	cardsContainer addChild: (self newDocCardForClass: BaselineOfArchC).
	cardsContainer addChild: (self newDocCardForClass: GtAndPharoExplanation).
	sectionContainer addChild: cardsContainer.
	^ sectionContainer
]
