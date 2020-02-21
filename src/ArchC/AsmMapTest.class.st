Class {
	#name : #AsmMapTest,
	#superclass : #AcIsaStatementParseTest,
	#category : #'ArchC-Tests'
}

{ #category : #tests }
AsmMapTest >> testMapBodyForm1A [
	" STR symbollist = int,
	where symbollist is empty (i.e. single id on the left)"
	| result map mapbodylist |
	result := self parseStatement: 'ac_asm_map m { "x" = 123; }'.
	self assert: result key equals: 'ac_map'.
	map := result value.
	self assert: map key equals: 'm'.
	mapbodylist := map value.
	self assert: (mapbodylist at: 123) equals: 'x'
]

{ #category : #tests }
AsmMapTest >> testMapBodyForm1B [
	" STR symbollist = int,
	where symbollist is non-empty (i.e. many ids on the left)"
	| result map mapbodylist |
	result := self parseStatement: 'ac_asm_map m { "x" = 123; }'.
	self assert: result key equals: 'ac_map'.
	map := result value.
	self assert: map key equals: 'm'.
	mapbodylist := map value.
		self halt. "What happens here is totally bogus: Y is discarded!"
]

{ #category : #tests }
AsmMapTest >> testMapBodyForm1MultiCardinal [
	"two definitions for the same key"
	| result |
	result := self parseStatement: 'ac_asm_map m { "x", "y" = 1; "x" = 2; }'.
		self halt. "BOGUS, need to understand what should happen here."
]

{ #category : #tests }
AsmMapTest >> testMapBodyForm2 [
	" id[a..b] = [c..d] "
	| result |
	result := self parseStatement: 'ac_asm_map m { "x"[0..3] = [10..13]; }'.
		self halt.
]
