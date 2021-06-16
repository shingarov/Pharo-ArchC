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

{ #category : #'*ArchC-Core' }
String >> replaceKeywords: aBlockOrDictionary [
	^self replaceKeywords: aBlockOrDictionary leftDelimiter: $< rightDelimiter: $>
]

{ #category : #'*ArchC-Core' }
String >> replaceKeywords: aBlockOrDictionary  leftDelimiter: ld rightDelimiter: rd [
	^aBlockOrDictionary isBlock
		ifTrue: [ self replaceKeywordsUsingBlock: aBlockOrDictionary leftDelimiter: ld rightDelimiter: rd ]
		ifFalse: [ self replaceKeywordsUsingBlock: [ :key |
				aBlockOrDictionary at: key ] leftDelimiter: ld rightDelimiter: rd ]

]

{ #category : #'*ArchC-Core' }
String >> replaceKeywordsUsingBlock: aBlock leftDelimiter: ld rightDelimiter: rd [
	| i j prefix key value rest |
	i := self indexOf: ld ifAbsent: [ ^self ].
	j := self indexOf: rd.
	prefix := self copyFrom: 1 to: i-1.
	key := self copyFrom: i+1 to: j-1.
	value := aBlock value: key.
	rest := self copyFrom: j+1 to: self size.
	^prefix, value, (rest replaceKeywords: aBlock leftDelimiter: ld rightDelimiter: rd)
	
]

{ #category : #'*ArchC-Core' }
String >> replaceValueKeywords: aBlockOrDictionary [
	^self replaceKeywords: aBlockOrDictionary leftDelimiter: ${ rightDelimiter: $}
]
