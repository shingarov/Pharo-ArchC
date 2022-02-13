Class {
	#name : #IslaParagraph,
	#superclass : #Object,
	#instVars : [
		'program'
	],
	#category : #Isla
}

{ #category : #compilation }
IslaParagraph >> analyzeContextFor: aKluiver [
	self subclassResponsibility
]

{ #category : #accessing }
IslaParagraph >> program [
	^ program
]

{ #category : #accessing }
IslaParagraph >> program: anObject [
	program := anObject
]
