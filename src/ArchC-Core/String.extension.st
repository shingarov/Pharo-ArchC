Extension { #name : #String }

{ #category : #'*ArchC-Core' }
String >> asOperandInstantiation [
	^AsmOperandInstantiation singleOperand: self
]

{ #category : #'*ArchC-Core' }
String >> getOSEnvironment [
	^((Smalltalk respondsTo: #isSmalltalkX) and: [ Smalltalk isSmalltalkX ])
		ifTrue: [#OperatingSystem asClass getEnvironment: self]
		ifFalse: [#OSEnvironment asClass current at: self ifAbsent: [ nil ]	]
]
