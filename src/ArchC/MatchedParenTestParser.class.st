Class {
	#name : #MatchedParenTestParser,
	#superclass : #AcCommonParser,
	#category : #'ArchC-Tests-Parsing'
}

{ #category : #'as yet unclassified' }
MatchedParenTestParser class >> example1 [
	MatchedParenTestParser new parse: 'asdf)'
]

{ #category : #grammar }
MatchedParenTestParser >> start [
	^matchedParen 
]
