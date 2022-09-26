Extension { #name : #BitVector }

{ #category : #'*ArchC-Core' }
BitVector >> decodeFor: anISA [
	^anISA decodeBits: self
]

{ #category : #'*ArchC-Core' }
BitVector >> toByteArrayEndian: endian [ 
	^ ByteArray 
		streamContents: [:stream | self toByteArrayEndian: endian on: stream ].
]

{ #category : #'*ArchC-Core' }
BitVector >> toByteArrayEndian: endian on: binaryStream [ 
	self assert: (self length \\ 8) == 0.
	self assert: (self length // 8) isPowerOfTwo.
	self isSymbolic ifTrue: [
		self error: 'Must be concrete!'.
		^ self
	].
	endian 
		ifBig: [
			self length - 1 to: 1 by: -8 do: [:pos | 
				| byte |

				byte := (self copyFrom: pos to: pos - 7) value.
				binaryStream nextPut: byte.
			].
		]
		ifLittle: [
			0 to: self length - 1 by: 8 do: [:pos | 
				| byte |

				byte := (self copyFrom: pos + 7 to: pos) value.
				binaryStream nextPut: byte.
			]
		].

	"
	 ((16r0A0B0C0D toBitVector: 32) toByteArray: Endian big) hexPrintString
	 ((16r0A0B0C0D toBitVector: 32) toByteArray: Endian little) hexPrintString
"
]
