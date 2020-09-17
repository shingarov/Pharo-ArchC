Class {
	#name : #PDLOpalPlugin,
	#superclass : #OCCompilerASTPlugin,
	#instVars : [
		'pdl'
	],
	#category : #'ArchC-Extras-Pharo'
}

{ #category : #private }
PDLOpalPlugin class >> priority [
	^100
]

{ #category : #private }
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
	[
	self processOperandNames.
	self transformPragmas: (ast pragmas select: [ :p | p selector = selAndPDL key])
	] on: Error do: [ ast methodPropertyAt: #ASM_FAILURE put: true. ^ast ].
	ast methodPropertyAt: #ISA put: pdl architectureName.
	^ast
]

{ #category : #private }
PDLOpalPlugin >> transformBinaryEncoding: bvs [
	| exprImms |
	ast body replaceWith: (ast methodClass template) ast copy body.
	(RBParseTreeRewriter replaceLiteral: #theInstruction with: bvs) executeTree: ast.
	
	"any Smalltalk expressions passed as immediate operands"
	exprImms := self variablesOccurringIn: bvs.
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

{ #category : #private }
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

{ #category : #private }
PDLOpalPlugin >> transformPragmas: anArray [
	| asmStatements instructions |
	asmStatements := anArray collect: #firstLiteralArgument.
	instructions := asmStatements collect: [  :s | (pdl assembler parse: s) binaryEncoding simplify ].
	self transformBinaryEncoding: instructions
]

{ #category : #private }
PDLOpalPlugin >> variablesOccurringIn: aCollectionOfASTs [
	^aCollectionOfASTs
		inject: Set new
		into: [ :soFar :thisAST | soFar addAll: thisAST variableNames. soFar ]
]
