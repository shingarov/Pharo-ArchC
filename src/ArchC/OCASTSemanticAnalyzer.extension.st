Extension { #name : #OCASTSemanticAnalyzer }

{ #category : #'*ArchC' }
OCASTSemanticAnalyzer >> undeclaredVariableXXXX: variableNode [
	variableNode replaceWith: (RBLiteralNode value: (SpecialVariable name: variableNode name))
]
