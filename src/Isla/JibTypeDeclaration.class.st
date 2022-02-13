Class {
	#name : #JibTypeDeclaration,
	#superclass : #JibStatement,
	#instVars : [
		'name',
		'type'
	],
	#category : #Isla
}

{ #category : #'instance creation' }
JibTypeDeclaration class >> name: n type: t [
	^self basicNew name: n; type: t; yourself

]

{ #category : #accessing }
JibTypeDeclaration >> name [
	^ name
]

{ #category : #accessing }
JibTypeDeclaration >> name: anObject [
	name := anObject
]

{ #category : #printing }
JibTypeDeclaration >> printOn: aStream [
	aStream nextPutAll: name.
	aStream nextPutAll: ' ∈ '.
	type printOn: aStream 
]

{ #category : #accessing }
JibTypeDeclaration >> type [
	^ type
]

{ #category : #accessing }
JibTypeDeclaration >> type: anObject [
	type := anObject
]
