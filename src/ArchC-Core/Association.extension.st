Extension { #name : #Association }

{ #category : #'*ArchC-Core' }
Association >> , anAssociation [ 
	^Dictionary newFromAssociations: (Array with: self with: anAssociation)
]

{ #category : #'*ArchC-Core' }
Association >> keysAndValuesDo: aBlock [
	"Adapt myself to Collection so that 'aDictionary, anAssociation' works."
	^aBlock value: self key value: self value
]
