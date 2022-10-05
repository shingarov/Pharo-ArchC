Extension { #name : #String }

{ #category : #'*BitVector' }
String >> /// xlen [
	^ self toBitVector: xlen

	"Created: / 04-10-2022 / 13:45:07 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*BitVector' }
String >> toBitVector: xlen [
	^ BitVector sym: self length: xlen
]
