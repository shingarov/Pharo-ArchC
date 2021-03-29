Extension { #name : #Association }

{ #category : #'*ArchC' }
Association >> , anAssociation [ 
	^Dictionary newFromAssociations: (Array with: self with: anAssociation)
]

{ #category : #'*ArchC' }
Association >> keysAndValuesDo: aBlock [
	"Adapt myself to Collection so that 'aDictionary, anAssociation' works."
	^aBlock value: self key value: self value
]
