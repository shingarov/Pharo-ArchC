Class {
	#name : #BitVectorToByteArrayConversionTest,
	#superclass : #TestCase,
	#category : #'ArchC-Core-Tests'
}

{ #category : #documentation }
BitVectorToByteArrayConversionTest class >> documentation [
"
	documentation to be added.

	[author:]
		Jan Vrany <jan.vrany@labware.com>

	[instance variables:]

	[class variables:]

	[see also:]

"
]

{ #category : #tests }
BitVectorToByteArrayConversionTest >> test1 [
	| bv ba |

	bv := 16r0A0B0C0D toBitVector: 32.
	ba := bv toByteArrayEndian: Endian big.
	self assert: ba first  equals: 16r0A.
	self assert: ba second equals: 16r0B.
	self assert: ba third  equals: 16r0C.
	self assert: ba fourth equals: 16r0D.
	bv := ba toBitVectorEndian: Endian big.
	self assert: bv value equals: 16r0A0B0C0D.

	bv:= 16r0A0B0C0D toBitVector: 32.
	ba := bv toByteArrayEndian: Endian little.
	self assert: ba first  equals: 16r0D.
	self assert: ba second equals: 16r0C.
	self assert: ba third  equals: 16r0B.
	self assert: ba fourth equals: 16r0A.     
	self assert: bv value equals: 16r0A0B0C0D.
	bv := ba toBitVectorEndian: Endian little.
	self assert: bv value equals: 16r0A0B0C0D.
]

{ #category : #tests }
BitVectorToByteArrayConversionTest >> test2 [
	| bv ba |

	bv := 16r0A0B toBitVector: 16.
	ba := bv toByteArrayEndian: Endian big.
	self assert: ba first  equals: 16r0A.
	self assert: ba second equals: 16r0B.
	bv := ba toBitVectorEndian: Endian big.
	self assert: bv value equals: 16r0A0B.

	bv:= 16r0A0B toBitVector: 16.
	ba := bv toByteArrayEndian: Endian little.
	self assert: ba first  equals: 16r0B.
	self assert: ba second equals: 16r0A.
	bv := ba toBitVectorEndian: Endian little.
	self assert: bv value equals: 16r0A0B.
]
