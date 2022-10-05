Class {
	#name : #BitVectorTest,
	#superclass : #TestCase,
	#category : #'BitVector-Tests'
}

{ #category : #tests }
BitVectorTest >> testBitAnd [
	| bvec mask test |

	bvec := 2r110110 toBitVector: 6.
	mask := 2r110010 toBitVector: 6.
	test := 2r110010 toBitVector: 6.

	self assert:  (bvec bitAnd: mask) equals: 2r110010.
	self assert:  (bvec bitAnd: mask) equals: test.

	bvec := (2r11 toBitVector:2) , ('x' toBitVector: 2) , (10 toBitVector: 2).
	mask := 2r110010 toBitVector: 6.
	test := 2r110010 toBitVector: 6.

	self assert: (bvec bitAnd: mask) equals: 2r110010.
	self assert: (bvec bitAnd: mask) equals: test.


	bvec := 2r110110 toBitVector: 6.
	mask := 2r110010 toBitVector: 6.
	test := 2r010010 toBitVector: 6.

	self assert: (bvec bitAnd: mask) equals: 2r110010.
	self deny:   (bvec bitAnd: mask) = test.

	bvec := (2r11 toBitVector:2) , ('x' toBitVector: 2) , (10 toBitVector: 2).
	mask := 2r110010 toBitVector: 6.
	test := 2r010010 toBitVector: 6.

	self assert: (bvec bitAnd: mask) equals: 2r110010.
	self deny:   (bvec bitAnd: mask) = test.
]

{ #category : #tests }
BitVectorTest >> testCopyFromTo [
	| bv1 bv2 |

	bv1 := 2r110110 toBitVector: 6.

	bv2 := bv1 copyFrom: 4 to: 2.
	self assert: bv2 length equals: 3.
	self assert: bv2 value = 2r101.

	bv2 := bv1 copyFrom: 5 to: 0.
	self assert: bv1 equals: bv2.

	bv1 := (16r6283 toBitVector: 16) , ('x' toBitVector: 16).
	bv2 := bv1 copyFrom: 31 to: 26.
	self assert: bv2 equals: 2r011000.
]
