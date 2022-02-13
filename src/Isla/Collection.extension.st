Extension { #name : #Collection }

{ #category : #'*Isla' }
Collection >> analyzeContextFor: aKluiver [
	"#analyzeContextFor: is a functor"
	^self collect: [ :x | x analyzeContextFor: aKluiver ]
]
