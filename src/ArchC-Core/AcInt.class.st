Class {
	#name : #AcInt,
	#superclass : #AcDataInstruction,
	#category : #'ArchC-Core-Core'
}

{ #category : #queries }
AcInt class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == AcInt.
]

{ #category : #'instance creation' }
AcInt class >> new [
	^ self value: 0
]

{ #category : #'encoding / decoding' }
AcInt >> assembler [
	^ (self name asParser trim,
		(   "hex literal"('0x' asParser, #hex asParser plus flatten ==> [ :prefAndnumeral | Integer readFrom: prefAndnumeral second  base: 16 ])
		  / "dec literal"(#digit asParser plus flatten ==> [ :numeralString | numeralString asInteger ])
		  / "{varname}"  (${ asParser, (PPPredicateObjectParser anyExceptAnyOf: #($})) star flatten, $} asParser ==> [ :expr | expr second])))
		  ==> [ :nameAndValue | self class value: nameAndValue second ].

	"
	AcByte basicNew assembler parse: '.byte 0x1'
	AcByte basicNew assembler parse: '.byte 255'
	AcByte basicNew assembler parse: '.byte {byteval}'
	"
]

{ #category : #'encoding / decoding' }
AcInt >> disassemble [
	binaryEncoding isSymbolic ifTrue: [
		| variables |

		variables := binaryEncoding variableNames.
		variables size == 1 ifTrue: [
			"Simple function of one variable"
			^ self name , ' {' , variables anyOne , '}'
		] ifFalse: [
			"Function of multiple variables, print the whole AST"
			^ self name , ' {' , binaryEncoding astToString , '}'
		].
	] ifFalse: [
		^ self name , ' 0x', (self value printPaddedWith:$0 to: self bitWidth // 8 base:16)
	].
]

{ #category : #'encoding / decoding' }
AcInt >> emitOn: aStream [
	self binaryEncoding toByteArrayEndian: self isa endian on: aStream
]

{ #category : #accessing }
AcInt >> value [
	^ self binaryEncoding unsignedValue
]

{ #category : #accessing }
AcInt >> value: value [
	binaryEncoding := value toBitVector: self bitWidth
]
