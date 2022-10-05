Class {
	#name : #BaselineOfBitVector,
	#superclass : #BaselineOf,
	#category : #BaselineOfArchC
}

{ #category : #baselines }
BaselineOfBitVector >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec
				package: #'BitVector';
				package: #'BitVector-Tests'.
		]
]
