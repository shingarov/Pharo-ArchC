"
I indicate the byte ordering that assigns the lowest address to the highest-order (""leftmost"") 8 bits of the scalar word.  I.e. the ""big end"" of the scalar, considered as a binary number, comes first in storage, such as on the 680x0 or the S/370.
"
Class {
	#name : #BigEndian,
	#superclass : #Endian,
	#category : #'ArchC-Core-Core'
}

{ #category : #controlling }
BigEndian >> ifBig: alternativeBlock [
	^alternativeBlock value
]

{ #category : #controlling }
BigEndian >> ifBig: beAlternativeBlock ifLittle: leAlternativeBlock [ 
	^beAlternativeBlock value
]

{ #category : #controlling }
BigEndian >> ifLittle: alternativeBlock [
	^nil
]

{ #category : #printing }
BigEndian >> printOn: aStream [
	aStream nextPutAll: 'BE'
]
