Extension { #name : #AcRelocation }

{ #category : #'*ArchC-DSL' }
AcRelocation class >> % symbol [
	^ (AcDSLSymbol value: 0)
		relocation: (self symbol: symbol);
		yourself
]
