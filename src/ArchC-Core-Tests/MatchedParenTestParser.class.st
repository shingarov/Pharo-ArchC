Class {
	#name : #MatchedParenTestParser,
	#superclass : #AcCommonParser,
	#category : #'ArchC-Core-Tests'
}

{ #category : #'as yet unclassified' }
MatchedParenTestParser class >> example1 [
	MatchedParenTestParser new parse: 'asdf)'
]

{ #category : #grammar }
MatchedParenTestParser >> start [
	^matchedParen 
]
