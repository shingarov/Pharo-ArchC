Class {
	#name : #AcStackCallingConvention,
	#superclass : #AcCallingConvention,
	#instVars : [
		'size',
		'alignment'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #accessing }
AcStackCallingConvention >> alignment [
	^ alignment
]

{ #category : #accessing }
AcStackCallingConvention >> alignment: anObject [
	alignment := anObject
]

{ #category : #accessing }
AcStackCallingConvention >> size1 [
	^ size
]

{ #category : #accessing }
AcStackCallingConvention >> size: anObject [
	size := anObject
]
