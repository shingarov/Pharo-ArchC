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

{ #category : #'as yet unclassified' }
PDLOpalPlugin >> processOperandNames [
	| opNames |
	opNames := ast pragmas select: [ :p | p selector = #operands: ].
	opNames isEmpty ifTrue: [ ^nil ].
	opNames := opNames first arguments first value collect: #asString.
	ast methodPropertyAt: #operand_names put: opNames 
]

{ #category : #api }
PDLOpalPlugin >> transform [
	| selAndPDL |
	selAndPDL := ast assemblyISA.
	selAndPDL isNil ifTrue: [ ^ast ].
	ast := ast copy.
	pdl := selAndPDL value.
	self processOperandNames.
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
	
	self transformOperandAccess.
	ast  doSemanticAnalysis .

]

{ #category : #api }
PDLOpalPlugin >> transformOperandAccess [
	| operandNames |
	operandNames := ast methodPropertyAt: #operand_names ifAbsent: [ ^nil ].
	operandNames doWithIndex: [ :operandName :operandIndex |
		| rrrrr |
		rrrrr := RBParseTreeRewriter 	new
			replaceTree: (RBVariableNode named: operandName)
			withTree: (RBMessageNode receiver: (RBSelfNode new)
				selector: #getOperand:
				arguments: (OrderedCollection with: 	(RBLiteralNode value: operandIndex))).
		rrrrr executeTree: ast ]
]

{ #category : #api }
PDLOpalPlugin >> transformPragmas: anArray [
	| asmStatements instructions |
	asmStatements := anArray collect: #firstLiteralArgument.
	instructions := asmStatements collect: [  :s | (pdl assembler parse: s) binaryEncoding ].
	instructions := BitVector concatAll: instructions.
	self transformBinaryEncoding: instructions simplify
]
