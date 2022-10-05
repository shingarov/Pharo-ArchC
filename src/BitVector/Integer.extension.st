Extension { #name : #Integer }

{ #category : #'*BitVector' }
Integer >> /// xlen [
	^ self toBitVector: xlen

	"Created: / 04-10-2022 / 13:45:07 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*BitVector' }
Integer >> toBitVector: xlen [
	^ BitVector value: self length: xlen
]
