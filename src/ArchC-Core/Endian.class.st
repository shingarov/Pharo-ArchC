"
I discriminate between the two possible ""byte orderings"", i.e. the arrangements of individually-addressable ""bytes"" of the machine word in storage, in the presence of arithmetic operations which ""carry"" in a distinguished direction (""leftward"").

As such, from a datatype perspective I am a co-product of two voids (i.e. I am isomorphic to the number 2).  Smalltalk-80 lacks a concise way of expressing this; we will rewrite this code when we have a more convenient notation.

Note on the choice of ""Endian"" vs ""Endianness"" for the name of the class:  in both the 1727 and the 1900 editions of ""Gulliver's Travels"" the word ""Endian"" occurs exactly like this six times, and the word ""Endianness"" zero times.  Knuth does use ""Endianness"" once in TAOCP, on page 139 of vol.4A.  The 15th edition of the Chicago Manual is silent about the subject.
"
Class {
	#name : #Endian,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'ArchC-Core-Core'
}

{ #category : #'instance creation' }
Endian class >> big [
	^BigEndian uniqueInstance
]

{ #category : #'instance creation' }
Endian class >> little [
	^LittleEndian uniqueInstance
]

{ #category : #'instance creation' }
Endian class >> new [
	self shouldNotImplement
]

{ #category : #'instance creation' }
Endian class >> uniqueInstance [
	self == Endian ifTrue: [ self error ].
	uniqueInstance isNil ifTrue: [ uniqueInstance := self basicNew ].
	^uniqueInstance
]
