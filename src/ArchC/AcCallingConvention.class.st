Class {
	#name : #AcCallingConvention,
	#superclass : #Object,
	#instVars : [
		'isReturn',
		'id'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
AcCallingConvention class >> callFor: id [
	^self new
		id: id;
		isReturn: false;
		yourself
]

{ #category : #'instance creation' }
AcCallingConvention class >> returnFor: id [
	^self new
		id: id;
		isReturn: true;
		yourself
]

{ #category : #accessing }
AcCallingConvention >> id [
	^ id
]

{ #category : #accessing }
AcCallingConvention >> id: anObject [
	id := anObject
]

{ #category : #accessing }
AcCallingConvention >> isReturn [
	^ isReturn
]

{ #category : #accessing }
AcCallingConvention >> isReturn: anObject [
	isReturn := anObject
]
