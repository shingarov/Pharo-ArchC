"
I am the superclass of the parsers for various ArchC documents,
providing common grammar elements such as 'comment', 'id' etc.
"
Class {
	#name : #AcCommonParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'id',
		'idList',
		'idListSpaceSeparated',
		'registerListSpaceSeparated',
		'matchedParen',
		'decimalNumber',
		'hexNumber',
		'number',
		'positiveNumber',
		'negativeNumber',
		'registerName',
		'str',
		'directory'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #accessing }
AcCommonParser class >> ignoredNames [
		"Answer a collection of instance-variables that should not be automatically initialized with productions, but that are used internal to the composite parser."

	   ^ super ignoredNames , #(directory)

]

{ #category : #API }
AcCommonParser class >> inWorkingDirectory: path [
	^self new
		directory: path;
		yourself
]

{ #category : #miscellaneous }
AcCommonParser class >> newline [
	^ (Character lf asParser)
	/ (Character cr asParser , Character lf asParser optional)
]

{ #category : #API }
AcCommonParser class >> parseFile: fileName in: path [
	| contents |

	"Do not remove #asString at the end: it is there for Smalltalk/X
	 compatibilty as #contents in Smalltalk/X returns a StringCollection
	 of lines!"
	contents := (path asFileReference / fileName) contents asString.
	^(self inWorkingDirectory: path)
		parse: contents
]

{ #category : #grammar }
AcCommonParser >> decimalNumber [
	^#digit asParser plus flatten ==> [ :x | x asInteger ]
]

{ #category : #accessing }
AcCommonParser >> directory [
	^directory
]

{ #category : #accessing }
AcCommonParser >> directory: dir [ 
	directory  := dir
]

{ #category : #grammar }
AcCommonParser >> hexNumber [
	^('0x' asParser , (#hex asParser plus flatten ))  ==> [ :x | Integer readFrom: x last base: 16  ]
]

{ #category : #grammar }
AcCommonParser >> id [
	^(#letter asParser, ($_ asParser / #word asParser) star) flatten
]

{ #category : #grammar }
AcCommonParser >> idList [
	^id, (($, asParser trim, id) ==> [ :x | x last ]) star
		==> [ :x | x last asSet add: (x first); yourself ]
]

{ #category : #grammar }
AcCommonParser >> idListSpaceSeparated [
	^id, ((#space asParser star, id) ==> [ :x | x last ]) star
		==> [ :x | x last asSet add: (x first); yourself ]
]

{ #category : #grammar }
AcCommonParser >> idN [
	"Example: Op1 parses as #('Op' 1), but Spec parses as #('Spec' nil)"
	^#letter asParser star flatten, decimalNumber optional
]

{ #category : #grammar }
AcCommonParser >> matchedParen [
	| begin end any expression inside  |
	begin := '(' asParser.
	end := ')' asParser.
	any := #any asParser.
	expression := PPDelegateParser new.
	inside := end not, ( expression / any ).
	expression setParser: begin, inside star, end flatten.
	^expression flatten
]

{ #category : #grammar }
AcCommonParser >> negativeNumber [
	^$- asParser, positiveNumber
	==> [ :x | x last negated ]
]

{ #category : #grammar }
AcCommonParser >> number [
	^positiveNumber / negativeNumber

]

{ #category : #context }
AcCommonParser >> parse: anObject withContext: aPPContext [
	^ super parse: (self strip: anObject) withContext: aPPContext
]

{ #category : #grammar }
AcCommonParser >> positiveNumber [
	^hexNumber / decimalNumber

]

{ #category : #grammar }
AcCommonParser >> registerListSpaceSeparated [
	^registerName, ((#space asParser star, registerName) ==> [ :x | x last ]) star
		==> [ :x | x last asSet add: (x first); yourself ]
]

{ #category : #grammar }
AcCommonParser >> registerName [
	| idPresent |
	idPresent := ( $$ asParser / $% asParser ) optional,
		(id / decimalNumber). 
	^idPresent flatten
]

{ #category : #grammar }
AcCommonParser >> str [
	| begin end any expression inside  |
	begin := '"' asParser.
	end := '"' asParser.
	any := #any asParser.
	expression := PPDelegateParser new.
	inside := end not, ( expression / any ).
	expression setParser: begin, inside star flatten, end flatten.
	^expression ==> [ :x | x second ]
]

{ #category : #parsing }
AcCommonParser >> strip: aStringOrStream [
	"Strip comments from given string or stream
	 and return a read stream (with comments stripped)"

	^ (AcCommentStripper strip: aStringOrStream) readStream
]
