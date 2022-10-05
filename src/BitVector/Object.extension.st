Extension { #name : #Object }

{ #category : #'*BitVector' }
Object >> isBitVector [
	"return false here; to be redefined in subclass(es)"

	^ false
]

{ #category : #'*BitVector' }
Object >> toBitVector: xlen [
	^ self error: 'Cannot coerce to bit vector'
]
