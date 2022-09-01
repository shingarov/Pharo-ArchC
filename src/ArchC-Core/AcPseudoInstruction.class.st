"
A pseudo instruction instances can be inserted to an instruction 
sequence but do not encode any real processor instruction and when
emitted, they take no space (they're zero bit-wide).

The most notable example of pseudo instruction is a label 
(see class `AcLabel`).

"
Class {
	#name : #AcPseudoInstruction,
	#superclass : #AcInstruction,
	#category : #'ArchC-Core-Core'
}

{ #category : #queries }
AcPseudoInstruction class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == AcPseudoInstruction.
]

{ #category : #converting }
AcPseudoInstruction >> asByteArray [
	^ #[]
]

{ #category : #accessing }
AcPseudoInstruction >> binaryEncoding [
	^ BitVector empty
]

{ #category : #accessing }
AcPseudoInstruction >> bitWidth [
	^ 0
]

{ #category : #'encoding / decoding' }
AcPseudoInstruction >> decodeBits: aBitVector [
   ^ nil
]

{ #category : #'encoding / decoding' }
AcPseudoInstruction >> emitOn: aStream [
	"Emit (encode) instruction on given (binary) stream. The instruction
	 must be fully grounded (that is: not symbolic) otherwise an error is
	 thrown.
	"

	"Intentionally do nothing."
]

{ #category : #converting }
AcPseudoInstruction >> inEnvironment: env [
	^ self
]

{ #category : #testing }
AcPseudoInstruction >> isPseudoInstruction [
	^ true
]

{ #category : #printing }
AcPseudoInstruction >> printOn: aStream [ 
	aStream nextPutAll: (self name); nextPutAll: ': '.
	aStream nextPutAll: self disassemble.
]
