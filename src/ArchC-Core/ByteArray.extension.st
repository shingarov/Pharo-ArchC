Extension { #name : #ByteArray }

{ #category : #'*ArchC-Core' }
ByteArray >> bitAnd: aByteArray [
	| answer |

	answer := self copy.
	1 to: (self size min: aByteArray size) do: [ :i |
		answer at: i put: ((self at: i) bitAnd: (aByteArray at: i))
	].
	^ answer

	"
	#[0 255 0 255] bitAnd: #[255 0 255 0]
	"
]

{ #category : #'*ArchC-Core' }
ByteArray >> bitOr: aByteArray [
	| answer |

	answer := self copy.
	1 to: (self size min: aByteArray size) do: [ :i |
		answer at: i put: ((self at: i) bitOr: (aByteArray at: i))
	].
	^ answer

	"
	#[0 255 0 255] bitOr: #[255 0 255 0]
	"
]

{ #category : #'*ArchC-Core' }
ByteArray >> toBitVector: xlen endian: endian startingAt: startIndex [
	self assert: (xlen \\ 8) == 0.
	self assert: (xlen // 8) isPowerOfTwo.

	endian ifBig: [
		^ (BitVector concatAll: ((startIndex to: startIndex + (xlen // 8) - 1 by:  1) collect: [ :i | (self at:i) toBitVector: 8] as: Array)) simplify
	] ifLittle: [
		^ (BitVector concatAll: ((startIndex + (xlen // 8) - 1 to: startIndex by: -1) collect: [ :i | (self at:i) toBitVector: 8] as: Array)) simplify
	].

	"
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVector: 32 endian: Endian little startingAt: 1
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVector: 32 endian: Endian big startingAt: 1
	"

	"Created: / 18-06-2024 / 22:32:07 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*ArchC-Core' }
ByteArray >> toBitVectorEndian: endian [
	^ self toBitVector: self size * 8 endian: endian startingAt: 1

	"
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVectorEndian: Endian little.
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVectorEndian: Endian big.
	"
]
