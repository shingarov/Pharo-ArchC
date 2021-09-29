Extension { #name : #ByteArray }

{ #category : #'*ArchC-Core' }
ByteArray >> toBitVectorEndian: endian [
	self assert: self size isPowerOfTwo.
	endian ifBig: [
		^ (BitVector concatAll: (self collect: [ :aByte | aByte toBitVector: 8] as: Array)) simplify
	] ifLittle: [
		^ (BitVector concatAll: (self reverse collect: [ :aByte | aByte toBitVector: 8] as: Array)) simplify
	].

	"
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVectorEndian: Endian little.
	#[ 16r0A 16r0B 16r0C 16r0D ] toBitVectorEndian: Endian big.
	"
]
