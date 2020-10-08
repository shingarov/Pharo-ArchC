Class {
	#name : #MatchedParenTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #tests }
MatchedParenTest >> testMissingLRight [
	| result |
	result := MatchedParenTestParser new parse: '(asdf'.
	self assert: result isPetitFailure 
]

{ #category : #tests }
MatchedParenTest >> testMissingLeft [
	| result |
	result := MatchedParenTestParser new parse: 'asdf)'.
	self assert: result isPetitFailure 
]

{ #category : #tests }
MatchedParenTest >> testSuccess [
	| result |
	result := MatchedParenTestParser new parse: '(asdf)'.
	self assert: result equals: '(asdf)'
]
