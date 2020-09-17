"
I preprocess the comments out of ArchC languages.
This is inconvenient to do in a PetitParser grammar.
"
Class {
	#name : #AcCommentStripper,
	#superclass : #Object,
	#category : #'ArchC-Core-Parsing'
}

{ #category : #API }
AcCommentStripper class >> strip: sourceString [
	"Return sourceString with comments stripped."
	^self stripSlashStar: (self stripSlashSlash: sourceString)
]

{ #category : #internal }
AcCommentStripper class >> stripSlashSlash: sourceString [
	| language line remover |
	remover := '//' asParser negate star flatten, '//' asParser optional ==> [ :x | x first, ' ' ].
	line := (#newline asParser negate star, #newline asParser) flatten
		==> [ :x | remover parse: x ].
	language := line star.
	^(language parse:  sourceString) inject: '' into: [ :a :b | a, b ]
]

{ #category : #internal }
AcCommentStripper class >> stripSlashStar: sourceString [
	| language commented |
	commented  := PPDelegateParser  new.
	language := '/*' asParser negate star end flatten  / commented.
	commented setParser: 
		'/*' asParser negate star flatten,
		'/*' asParser ,
		'*/' asParser negate star ,
		'*/' asParser,
		language ==> [ :x | x first, x last ].
	^language parse:  sourceString
]
