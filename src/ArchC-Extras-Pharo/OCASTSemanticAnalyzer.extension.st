Extension { #name : #OCASTSemanticAnalyzer }

{ #category : #'*ArchC-Extras-Pharo' }
OCASTSemanticAnalyzer >> undeclaredVariableXXXX: variableNode [
	variableNode replaceWith: (RBLiteralNode value: (SpecialVariable name: variableNode name))
]
