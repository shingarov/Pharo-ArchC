"
I am the top-level PDL parser.
I start from parsing <isaname>.ac and answer an AcProcessorDescription.

"
Class {
	#name : #AcArchParser,
	#superclass : #AcCommonParser,
	#instVars : [
		'processorDescription',
		'memSize',
		'mem',
		'regbank',
		'component',
		'reg',
		'processorName',
		'wordsize',
		'ctor',
		'endian',
		'isa',
		'doubleQuoted',
		'ctorComponent',
		'definesGdb',
		'gdb'
	],
	#category : #'ArchC-Core-Parsing'
}

{ #category : #private }
AcArchParser class >> parseGdbFeatures: fileName in: directory [
	| featuresParserClass |
	featuresParserClass := Smalltalk at: #GdbXmlParser ifAbsent: [ ^nil ].
	^featuresParserClass parseFile: fileName in: directory
]

{ #category : #private }
AcArchParser class >> parseGdbFeatures: fileName in: directory assumeEndian: aSymbol [
	| featuresParserClass |
	featuresParserClass := Smalltalk at: #GdbXmlParser ifAbsent: [ ^nil ].
	^featuresParserClass parseFile: fileName in: directory assumeEndian: aSymbol
]

{ #category : #API }
AcArchParser class >> processor: processorName in: path [
	| f s |
	f := FileStream fileNamed:
		path,
		'/',
		processorName,
		'.ac'.
	s := f contentsOfEntireFile.
	f close.
	s := AcCommentStripper strip: s.
	^(self inWorkingDirectory: path)
		processorName: processorName;
		parse: s
]

{ #category : #grammar }
AcArchParser >> component [
	^mem /
	reg /
	regbank /
	wordsize /
	ctor
]

{ #category : #grammar }
AcArchParser >> ctor [
	^'ARCH_CTOR(' asParser trim, id, ')' asParser trim,
	${ asParser,
	ctorComponent trim star,
	'};' asParser
	==> [ :x | x at: 5 ]
]

{ #category : #grammar }
AcArchParser >> ctorComponent [
	^endian trim /
	isa trim /
	gdb trim /
	definesGdb trim
]

{ #category : #grammar }
AcArchParser >> definesGdb [
	^'defines_gdb("' asParser,
	$" asParser negate star flatten,
	'");' asParser
	==> [ :x | 'defines_gdb' ->  (AcDefinesParser parseFile: x second in: directory) ]
]

{ #category : #grammar }
AcArchParser >> doubleQuoted [
	$" asParser, $" asParser negate star flatten, $" asParser 
		==> [ :x | x second ]
]

{ #category : #grammar }
AcArchParser >> endian [
	^('set_endian("little");' asParser ==> [ :x | 'endian' -> Endian little ]) /
	('set_endian("big");' asParser ==> [ :x | 'endian' -> Endian big ])
]

{ #category : #grammar }
AcArchParser >> gdb [
	^'ac_gdb("' asParser,
	$" asParser negate star flatten,
	'");' asParser
	==> [ :x | 'ac_gdb' -> nil "(GdbXmlParser parseFile: x second in: directory)" ]
]

{ #category : #grammar }
AcArchParser >> isa [
	^'ac_isa("' asParser,
	$" asParser negate star flatten,
	'");' asParser
	==> [ :x | 'ac_isa' ->  (AcIsaParser parseFile: x second in: directory) ]
]

{ #category : #grammar }
AcArchParser >> mem [
	^'ac_mem' asParser trim, id, $: asParser, memSize, $; asParser ==>
		[ :x | Array with: 'ac_mem' -> ((x at: 2) -> (x at: 4)) ]
]

{ #category : #grammar }
AcArchParser >> memSize [
	^(decimalNumber, $K asParser ==> [ :x | x first * 1024 ] ) /
	(decimalNumber, $M asParser ==> [ :x | x first * 1024 * 1024 ] ) /
	(decimalNumber, $G asParser ==> [ :x | x first * 1024 * 1024 * 1024 ] ) /
	decimalNumber
]

{ #category : #grammar }
AcArchParser >> processorDescription [
	^'AC_ARCH(' asParser trim, id, ')' asParser,
	'{' asParser trim,
	component trim star,
	'};' asParser trim
	==> [ :x | x second -> x fifth  ]
]

{ #category : #grammar }
AcArchParser >> processorName [
	^processorName
]

{ #category : #grammar }
AcArchParser >> processorName: aString [
	processorName  := aString 
]

{ #category : #grammar }
AcArchParser >> reg [
	^('ac_reg' asParser,
	('<' asParser, decimalNumber, '>' asParser) optional) trim,
	idList,
	';' asParser
		==> [ :x | x second collect: [ :regName | Association key: 'ac_reg' value: regName ] ]
]

{ #category : #grammar }
AcArchParser >> regbank [
	^'ac_regbank' asParser trim, id, $: asParser, decimalNumber, $; asParser ==>
	[ :x | Array with: 'ac_regbank' -> ((x at: 2) -> (x at: 4)) ]
]

{ #category : #grammar }
AcArchParser >> start [
	^processorDescription end
	==> [ :x |
		| components |
		components := x value asOrderedCollection.
		components := components 
			inject: (OrderedCollection
				with: 'SEMANTICS' -> (AcCompilerInfoParser parseFile: 'compiler_info.ac' in: directory)
				"with: 'LWISEM' -> (LWISEMParser parseFile: 'lwisem' in: directory)")
			into: [ :soFar :elem | soFar addAll: elem; yourself ].
		AcProcessorDescription new
			architectureName: (x key);
			fillFrom: components;
			yourself ]
]

{ #category : #grammar }
AcArchParser >> wordsize [
	^'ac_wordsize' asParser trim, decimalNumber, $; asParser
		==> [ :x | Array with: 'ac_wordsize' -> x second ]
]
