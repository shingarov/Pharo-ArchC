"
I indicate the byte ordering that assigns the lowest address to the lowest-order (""rightmost"") 8 bits of the scalar word.  I.e. the ""little end"" of the scalar, considered as a binary number, comes first in storage, such as on the x86 or the VAX.
"
Class {
	#name : #LittleEndian,
	#superclass : #Endian,
	#category : #'ArchC-Core-Core'
}

{ #category : #controlling }
LittleEndian >> ifBig: alternativeBlock [
	^nil
]

{ #category : #controlling }
LittleEndian >> ifBig: beAlternativeBlock ifLittle: leAlternativeBlock [ 
	^leAlternativeBlock value
]

{ #category : #controlling }
LittleEndian >> ifLittle: alternativeBlock [
	^alternativeBlock value
]

{ #category : #printing }
LittleEndian >> printOn: aStream [
	aStream nextPutAll: 'LE'
]
