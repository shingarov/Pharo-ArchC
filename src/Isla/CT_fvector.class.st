Class {
	#name : #'CT_fvector',
	#superclass : #IslaWrapperType,
	#instVars : [
		'n'
	],
	#category : #Isla
}

{ #category : #accessing }
CT_fvector >> n [
	^ n
]

{ #category : #accessing }
CT_fvector >> n: size [
	n := size
]
