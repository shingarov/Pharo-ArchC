Class {
	#name : #StringKeywordTokenTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testEmpty [
	| result |
	result := '' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: ''
]

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testFull [
	| result |
	result := 'ab<Z>cd' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'abXXXcd'
]

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testKeyAtLeft [
	| result |
	result := '<Z>cd' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'XXXcd'
]

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testKeyAtRight [
	| result |
	result := 'ab<Z>' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'abXXX'
]

{ #category : #'tests-value interpretation' }
StringKeywordTokenTest >> testMixedValue [
	| source result |
	source := 'ab{Z}<c>d'.
	result := source replaceValueKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'abXXX<c>d'.
	result := source replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'ab{Z}XXXd'
]

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testNoKeywords [
	| result |
	result := 'abcd' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'abcd'
]

{ #category : #'tests-substitution' }
StringKeywordTokenTest >> testTwoKeys [
	| d result |
	d := Dictionary new
		at: 'x' put: 'XXX';
		at: 'y' put: 'YYY';
		yourself.
	result := '<x>abcd<y>' replaceKeywords: d.
	self assert: result equals: 'XXXabcdYYY'
]

{ #category : #'tests-value interpretation' }
StringKeywordTokenTest >> testValue [
	| result |
	result := 'ab{Z}cd' replaceValueKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'abXXXcd'
]

{ #category : #'tests-value interpretation' }
StringKeywordTokenTest >> testValueResistance [
	| result |
	result := 'ab{Z}cd' replaceKeywords: [ :key | 'XXX' ].
	self assert: result equals: 'ab{Z}cd'
]
