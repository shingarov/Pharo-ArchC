Class {
	#name : #AcRelocation,
	#superclass : #Object,
	#instVars : [
		'symbol',
		'addend'
	],
	#classVars : [
		'AddressOutOfRange'
	],
	#category : #'ArchC-Core-Relocations'
}

{ #category : #initialization }
AcRelocation class >> initialize [
	AddressOutOfRange := 16r1FFFFFFFFFFFFFFFF
]

{ #category : #queries }
AcRelocation class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == AcRelocation.
]

{ #category : #queries }
AcRelocation class >> isValidForInstruction: insn [
	"Return `true` this relocation is valid for fiven instruction (or instruction declaration).
	 Otherwise, return `false`."

	^ self subclassResponsibility
]

{ #category : #'instance creation' }
AcRelocation class >> new [
	^ self shouldNotImplement. "Use #symbol: instead"
]

{ #category : #'instance creation' }
AcRelocation class >> symbol: symbol [
	^ self symbol: symbol addend: 0
]

{ #category : #'instance creation' }
AcRelocation class >> symbol: symbol addend: addend [
	^ self basicNew initializeWithSymbol: symbol addend: addend
]

{ #category : #accessing }
AcRelocation >> addend [
	^ addend
]

{ #category : #accessing }
AcRelocation >> addend: anInteger [
	self assert: anInteger isInteger.

	addend := anInteger.
]

{ #category : #'processing - simplified' }
AcRelocation >> calculateS: s A: a P: p [
	"Calculate relocation value (either relative of absolute, depending
	 on relocation type) and return it. If the value is out of range,
	 return special value `AddressOutOfRange`.

	 Parameters:

		s ... final address of the symbol in memory
		a ... addend field of the relocation entry
		p ... position of the relocation (address of instruction being relocated)

	 NOTE: this method is part of a 'simplified' relocation processing.
	 If the relocation requires GOT / TOC entry or PLT entry (or any other
	 value other than those given), you highly likely want to override
	 #fixup:symbols:relocation: method!
	"
	^ self subclassResponsibility
]

{ #category : #'printing & storing' }
AcRelocation >> disassembleOn: aStream [
	aStream nextPutAll: self class name.
	aStream space.
	aStream nextPutAll: symbol asString.
	addend ~~ 0 ifTrue: [
		aStream space.
		aStream nextPut:(addend < 0 ifTrue: [ $- ] ifFalse: [ $+ ]).
		aStream space.
		addend abs printOn: aStream
	].
]

{ #category : #displaying }
AcRelocation >> displayOn: aStream [
	aStream nextPutAll: self class name.
	aStream space.
	aStream nextPutAll: symbol asString.
	addend ~~ 0 ifTrue: [
		aStream nextPutAll: ' + '.
		addend printOn: aStream
	].
]

{ #category : #displaying }
AcRelocation >> displayStringOn: aStream [
	"For Pharo compatibility"
	self displayOn: aStream
]

{ #category : #'processing - simplified' }
AcRelocation >> fixup: memory at: address with: value [
	"Patch instruction at `address` with `value`."

	self subclassResponsibility
]

{ #category : #processing }
AcRelocation >> fixup: memory symbols: symbols relocations: relocations [
	"Process this relocation and patch (binary) instructions.

	 If relocation symbol address is not (yet) known (that is, not present
	 in `symbols` dictionary), throw `AcRelocationSymbolUnresolved`.

	 If the code cannot be fixed up because of value over/underflow, throw
	 `AcRelocationOverflow`.

	 If the code cannot be fixed up for any other reasons, throw generic
	 `AcRelocationFailed`.

	 Parameters:

	 * `memory` is a byte-array like object containing binary code.
	 * `symbols` is a dictionary mapping (known) symbols to their respective
	   addresses.
	 * `relocations` is a dictionary mapping relocations to their respective
	   addresses.

	 NOTE: the below (default) code implements so-called 'simplified' processing
	 for relocations that do not need any GOT / TOC entries or PLT entries and
	 do not perform relaxation. If the relocation type requires any of that,
	 you likely need to override this method.
	"
	| s a p v |

	(symbols includesKey: symbol) ifFalse: [
		AcRelocationSymbolUnresolved new
			relocation: self;
			signal: 'Relocation symbol is unresolved (symbol address is not known)'.
		^ self
	].
	(relocations includesKey: self) ifFalse: [
		AcRelocationFailed new
			relocation: self;
			signal: 'Relocation position is not known!'. "This should not happen!"
		^ self
	].


	s := symbols at: symbol.
	a := addend.
	p := relocations at: self.

	v := self calculateS: s A: a P: p.
	v == AddressOutOfRange ifTrue: [
		AcRelocationOverflow new
			relocation: self;
			signal: 'Relocation overflow'.
		^ self
	].

	self fixup: memory at: p with: v
]

{ #category : #initialization }
AcRelocation >> initializeWithSymbol: symbolObj addend: addendObj [
	self symbol: symbolObj.
	self addend: addendObj.
]

{ #category : #testing }
AcRelocation >> isAcRelocation [
	^ true
]

{ #category : #testing }
AcRelocation >> isValidForInstruction: insn [
	^ self class isValidForInstruction: insn
]

{ #category : #copying }
AcRelocation >> postCopy [
	symbol := symbol copy
]

{ #category : #accessing }
AcRelocation >> symbol [
	^ symbol
]

{ #category : #accessing }
AcRelocation >> symbol: anObject [
	self assert: (symbol isNil or: [ symbol = anObject ]).

	symbol := anObject.
]
