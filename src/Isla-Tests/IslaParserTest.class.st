Class {
	#name : #IslaParserTest,
	#superclass : #TestCaseWithZ3Context,
	#category : #'Isla-Tests'
}

{ #category : #'tests - expressions' }
IslaParserTest >> testApplication [
	| f fBody ssa application |
	f := KluiverParser parse: 'fn f(x, y) {
   a = g(c, d);
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	application := ssa expression.
	self assert: application functor equals: 'g'.
	self assert: application args equals: #(#('c') #('d')).
]

{ #category : #'tests - expressions' }
IslaParserTest >> testApplicationComposition [
	| f fBody ssa applicationG applicationF |
	f := KluiverParser parse: 'fn f(x, y) {
   a = g(f(()));
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	applicationG := ssa expression.
	self assert: applicationG functor equals: 'g'.
	applicationF := applicationG args first.
	self assert: applicationF functor equals: 'f'.
	self assert: applicationF args first literal isNil
]

{ #category : #'tests - expressions' }
IslaParserTest >> testApplicationToString [
	| f fBody ssa application |
	f := KluiverParser parse: 'fn f(x, y) {
   a = g("asdf");
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	application := ssa expression.
	self assert: application functor equals: 'g'.
	self assert: application args first literal equals: 'asdf'
]

{ #category : #'tests - expressions' }
IslaParserTest >> testApplicationToUnit [
	| f fBody ssa application |
	f := KluiverParser parse: 'fn f(x, y) {
   a = g(());
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	application := ssa expression.
	self assert: application functor equals: 'g'.
	self assert: application args first literal isNil
]

{ #category : #tests }
IslaParserTest >> testAs [
	| f |
	f := KluiverParser parse: 'fn f(ze) {
  zz41 = ze as a.b;
}'.
	self assert: f name equals: 'f'.
]

{ #category : #'tests - expressions' }
IslaParserTest >> testEmptyQuotedString [
	| f fBody ssa |
	f := KluiverParser parse: 'fn f(x, y) {
   a = "";
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal equals: ''.
]

{ #category : #tests }
IslaParserTest >> testEnum [
	| e |
	e := KluiverParser parse: 'enum zbop {
   zRISCV_BEQ,
   zRISCV_BNE,
   zRISCV_BGEU
}'.
	self assert: (e isKindOf: IslaEnum).
	self assert: e name equals: 'zbop'.
	
]

{ #category : #tests }
IslaParserTest >> testFVec [
	| f fvec |
	f := KluiverParser parse: 'val f : (%i) ->  %fvec(32, %string)'.
	self assert: f name equals: 'f'.
	fvec := f type value.
	self assert: fvec n equals: 32.
]

{ #category : #tests }
IslaParserTest >> testFailure [
	| f |
	f := KluiverParser parse: 'fn f(x) {
  failure;
}'.
	self assert: f name equals: 'f'.
	self assert: (f members first isKindOf: JibFailure)
	
]

{ #category : #tests }
IslaParserTest >> testFn1 [
	| f fBody |
	f := KluiverParser parse: 'fn f(x, y) {
   z : %bv32 `6 1:2-3:4;
   goto 12345;
   end;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 3
]

{ #category : #'tests - expressions' }
IslaParserTest >> testFortyTwo [
	| f fBody ssa |
	f := KluiverParser parse: 'fn f(x, y) {
   a = 42;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal equals: 42
]

{ #category : #'tests - expressions' }
IslaParserTest >> testFortyTwoInBinary [
	| f fBody ssa |
	f := KluiverParser parse: 'fn f(x, y) {
   a = 0b101010;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal equals: 42
]

{ #category : #'tests - expressions' }
IslaParserTest >> testFortyTwoInHex [
	| f fBody ssa |
	 f := KluiverParser parse: 'fn f(x, y) {
   a = 0x2A;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal equals: 42
]

{ #category : #tests }
IslaParserTest >> testJumpIs [
	| f |
	f := KluiverParser parse: 'fn f(x) {
  jump x is y goto 4;
}'.
	self assert: f name equals: 'f'.
]

{ #category : #'tests - expressions' }
IslaParserTest >> testLet [
	| r |
	r := KluiverParser parse: 'let (x: %i) {
  zz40 = ();
}'.
	self assert: r name equals: 'x'.
	self assert: r type equals: Int sort.
	self assert: r members size equals: 1
	
]

{ #category : #tests }
IslaParserTest >> testList [
	| e f arg1 |
	f := KluiverParser parse: 'val f : (%list(%enum e)) ->  %enum e'.
	self assert: f name equals: 'f'.
	arg1 := f type key first. "the list"
	e := arg1 elementType.
	self assert: e id equals: 'e'.
]

{ #category : #'tests - expressions' }
IslaParserTest >> testProjection [
	| f fBody ssa projection |
	f := KluiverParser parse: 'fn f(x, y) {
   a = b.c.d;
   end;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 2.
	ssa := fBody first.
	projection := ssa expression.
	self assert: projection equals: #('b' 'c' 'd')
]

{ #category : #'tests - expressions' }
IslaParserTest >> testProjectionTrivial [
	| f fBody ssa projection |
	f := KluiverParser parse: 'fn f(x, y) {
   a = b;
   end;
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 2.
	ssa := fBody first.
	projection := ssa expression.
	self assert: projection equals: #('b')
]

{ #category : #'tests - expressions' }
IslaParserTest >> testQuotedString [
	| f fBody ssa |
	f := KluiverParser parse: 'fn f(x, y) {
   a = "asdf";
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal equals: 'asdf'.
]

{ #category : #'tests - expressions' }
IslaParserTest >> testRegister [
	| r |
	r := KluiverParser parse: 'register pc : %i'.
	self assert: r name equals: 'pc'.
	self assert: r type equals: Int sort.
	
]

{ #category : #tests }
IslaParserTest >> testStruct [
	| s |
	s := KluiverParser parse: 'struct zProcState {
  zA: %bv1,
  zBTYPE: %bv2,
  zC: %bv1,
  zD: %bv1,
  zDIT: %bv1,
  zE: %bv1,
  zEL: %bv2,
  zF: %bv1,
  zGE: %bv4,
  zI: %bv1,
  zIL: %bv1,
  zIT: %bv8,
  zJ: %bv1,
  zM: %bv5,
  zN: %bv1,
  zPAN: %bv1,
  zQ: %bv1,
  zSP: %bv1,
  zSS: %bv1,
  zSSBS: %bv1,
  zT: %bv1,
  zTCO: %bv1,
  zUAO: %bv1,
  zV: %bv1,
  zZ: %bv1,
  znRW: %bv1
}'.
	self assert: s name equals: 'zProcState'.
	self assert: s members first key equals: 'zA'.
	self assert: s members first value length equals: 1.
	
]

{ #category : #tests }
IslaParserTest >> testUnion1 [
	| u |
	u := KluiverParser parse: 'union zexception {
   zError_internal_error: %real,
   zError_not_implemented: %string
}'.
	self assert: u name equals: 'zexception'.
	self assert: u members size equals: 2.
]

{ #category : #tests }
IslaParserTest >> testUnion2 [
	| u |
	 u := KluiverParser parse: 'union u {
   x: %unit,
   y: %struct s
}'.
	self assert: u name equals: 'u'.
	self assert: u members second value id equals: 's'.
	
]

{ #category : #'tests - expressions' }
IslaParserTest >> testUnit [
	| f fBody ssa |
	f := KluiverParser parse: 'fn f(x, y) {
   a = ();
}'.
	self assert: f name equals: 'f'.
	self assert: f args size equals: 2.
	fBody := f members.
	self assert: fBody size equals: 1.
	ssa := fBody first.
	self assert: ssa expression literal isNil
]

{ #category : #tests }
IslaParserTest >> testVal [
	| f sig |
	f := KluiverParser parse: 'val f : (%i, %bv32,%bv, %i64) ->  %unit'.
	self assert: f name equals: 'f'.
	sig := f type.
	self assert: sig key size equals: 4.
	self assert: sig key first name asString equals: 'Int'.
	self assert: sig key second name asString equals: 'bv'.
	self assert: sig key third         equals: #BV.
	self assert: sig key fourth        equals: #IXX.
]

{ #category : #tests }
IslaParserTest >> testValDescription [
	| x |
	x := KluiverParser parse: 'val x = "internal_x" : (%unit) -> %i'.
	self assert: x name equals: 'x'.
	self assert: x description equals: 'internal_x'.
]

{ #category : #tests }
IslaParserTest >> testValFromVoid [
	| f sig |
	f := KluiverParser parse: 'val f : (%unit) ->  %i'.
	self assert: f name equals: 'f'.
	sig := f type.
	self assert: sig key size equals: 1.
	self assert: sig key first isNil. "implement Z3 Unit???"
	self assert: sig value equals: Int sort
]

{ #category : #tests }
IslaParserTest >> testVec [
	| f arg1 |
	f := KluiverParser parse: 'val f : (%vec(%enum e)) ->  %enum e'.
	self assert: f name equals: 'f'.
	arg1 := f type key first. "the vec"
	self assert: arg1 elementType sort equals: '%enum'.
]
