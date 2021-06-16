Class {
	#name : #ParsingDone,
	#superclass : #ParsingState,
	#category : #'ArchC-LibreSOC'
}

{ #category : #logic }
ParsingDone >> isAccepting [ 
	^true
]

{ #category : #logic }
ParsingDone >> transition: l [
	self shouldNotImplement 
]
