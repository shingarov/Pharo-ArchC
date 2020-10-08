Class {
	#name : #AcMnemonicConstraintConstant,
	#superclass : #AcMnemonicConstraint,
	#instVars : [
		'c'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #accessing }
AcMnemonicConstraintConstant >> c [
self halt.
	^ c
]

{ #category : #accessing }
AcMnemonicConstraintConstant >> c: anObject [
	c := anObject
]

{ #category : #API }
AcMnemonicConstraintConstant >> satisfy: env [
	^(env at: op ifAbsent: [ nil ]) = c
]
