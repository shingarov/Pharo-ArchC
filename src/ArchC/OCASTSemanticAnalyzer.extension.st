Extension { #name : #OCASTSemanticAnalyzer }

{ #category : #'*ArchC' }
OCASTSemanticAnalyzer >> undeclaredVariable: variableNode [
	variableNode replaceWith: (RBLiteralNode value: (SpecialVariable name: variableNode name))
]
