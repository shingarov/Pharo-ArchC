Extension { #name : #Association }

{ #category : #'*Isla' }
Association >> analyzeContextFor: aKluiver [
	"#analyzeContextFor: is a functor"
	^(self key analyzeContextFor: aKluiver) -> (self value analyzeContextFor: aKluiver)
]
