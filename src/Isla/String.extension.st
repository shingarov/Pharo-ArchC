Extension { #name : #String }

{ #category : #'*Isla' }
String >> charPositionOf: aPoint [
	^self class charPositionOf: aPoint in: self lines
]

{ #category : #'*Isla' }
String class >> charPositionOf: aPoint in: lines [
	aPoint y = 1 ifTrue: [ "base case"
		aPoint x <= lines first size
			ifTrue: [ ^aPoint x ]
			ifFalse: [ SubscriptOutOfBounds signalFor: aPoint ]].
	
	^(self
		charPositionOf: aPoint x @ (aPoint y - 1)
		in: lines allButFirst)
	+ lines first size + 1
]
