Extension { #name : #OCASTSemanticAnalyzer }

{ #category : #'*ArchC-Core' }
OCASTSemanticAnalyzer >> undeclaredVariableXXXX: variableNode [
	variableNode replaceWith: (RBLiteralNode value: (SpecialVariable name: variableNode name))
]
