Class {
	#name : #PDLOpalPlugin,
	#superclass : #OCCompilerASTPlugin,
	#instVars : [
		'pdl'
	],
	#category : #'ArchC-Opal'
}

{ #category : #private }
PDLOpalPlugin class >> priority [
	^100
]

{ #category : #api }
PDLOpalPlugin >> transform [
	| selAndPDL |
	selAndPDL := ast assemblyISA.
	selAndPDL isNil ifTrue: [ ^ast ].
	ast := ast copy.
	pdl := selAndPDL value.
	self transformPragmas: (ast pragmas select: [ :p | p selector = selAndPDL key]).
	ast methodPropertyAt: #isASMMethod put: true.
	ast methodPropertyAt: #ISA put: pdl architectureName.
	^ast
]

{ #category : #api }
PDLOpalPlugin >> transformBinaryEncoding: bv [
	| exprImms |
	ast body replaceWith: (ArchCOpalTest >> #template) ast copy body.
	
	(RBParseTreeRewriter replaceLiteral: #theInstruction with: bv) executeTree: ast.
	
	"any Smalltalk expressions passed as immediate operands"
	exprImms := bv variableNames asOrderedCollection.
	exprImms doWithIndex: [ :expr :i | 
		| s ret rule |
		s := ast source asString lines first,
			' theEnvironment at: ''', expr, ''' put: (', expr, ')'.
		ret := RBParser parseMethod: s.
		ret := ret body statements first.
		rule := RBParseTreeRewriter 	new
			replaceTree: (RBLiteralNode value: i)
			withTree: ret.
		rule executeTree: ast.
		 ].
	ast  doSemanticAnalysis .

]

{ #category : #api }
PDLOpalPlugin >> transformPragmas: anArray [
	| asmStatements instructions |
	asmStatements := anArray collect: #firstLiteralArgument.
	instructions := asmStatements collect: [  :s | (pdl assembler parse: s) binaryEncoding ].
	instructions := BitVector concatAll: instructions.
	self transformBinaryEncoding: instructions simplify
]
