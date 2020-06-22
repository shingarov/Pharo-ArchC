Class {
	#name : #InstructionMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'instruction'
	],
	#category : #'ArchC-DUI'
}

{ #category : #'instance creation' }
InstructionMorph class >> on: anInstruction [
	^self new
		instruction: anInstruction;
		yourself
]

{ #category : #'instance creation' }
InstructionMorph class >> openOn: anInstruction [
	^(self on: anInstruction) openInWorld
]

{ #category : #testing }
InstructionMorph class >> openTest1 [
	"   InstructionMorph openTest1    "
	| instruction |
	instruction := AcProcessorDescriptions powerpc instructionAt: #addi.
	self openOn: instruction 
]

{ #category : #testing }
InstructionMorph class >> xxx [
	" InstructionMorph xxx "
	| morph |
	morph := TextMorph  new.
	morph
contents: 
'blah
this not only
crappy
but evil
as well
and
as hell';
fontName: 'Bitmap DejaVu Sans' pointSize: 14;
backgroundColor: (Color white);
wrapFlag: true;
halt;
bounds: (0@0 corner: 1000@500);
enabled: true;
autoFit: true.
^morph
]

{ #category : #drawing }
InstructionMorph >> bitBox [
	^ (self bounds translateBy: 0@28) origin extent: (self bounds width@32)

]

{ #category : #fonts }
InstructionMorph >> bitNumberFont [
	| font  |
	font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 8.
	^ font
]

{ #category : #fonts }
InstructionMorph >> costFont [
	| font  |
	font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 10.
	^ font emphasis: TextEmphasis bold emphasisCode
]

{ #category : #drawing }
InstructionMorph >> defaultBounds [
	"Answer the default bounds for the receiver."

	^0 @ 0 corner: 500 @ 300
]

{ #category : #drawing }
InstructionMorph >> drawBitGridOn: aCanvas [
	aCanvas
		frameAndFillRectangle: self bitBox 
		fillColor: Color white
		borderWidth: 2
		borderColor: Color black.
	
	
	1 to: 31 do: [ :i |
		| x subscript centerOfCell |
		x := self stumpX: i.
		subscript := (32 - i) asString.
		centerOfCell := x - (self bounds width - 2 // 32  // 2).
		self drawStump: i on: aCanvas. 
		aCanvas
			drawString: subscript
			at: (centerOfCell - ((self bitNumberFont widthOfString: subscript)//2)) @ self bitBox bottom
			font: self bitNumberFont
			color: Color blue]
]

{ #category : #drawing }
InstructionMorph >> drawCost: anInteger on: aCanvas y: y hasDelaySlot: aBoolean [
	| costString font width rect |

	rect := self bitBox right - 24 @ (y+2) extent: 23@19.
	aCanvas	
		frameAndFillRectangle: rect
		fillColor: (aBoolean ifTrue: [Color blue] ifFalse: [Color black])
		borderWidth: 0
		borderColor: Color black.

	costString := anInteger asString.
	font := self costFont.
	width := font widthOfString: costString.
	aCanvas 
		drawString: costString 
		at: (rect left + rect right - width // 2) @ (y+4)
		font: font 
		color: Color white

]

{ #category : #drawing }
InstructionMorph >> drawField: fieldName on: aCanvas left: left right: right [
	| x string  font width |
	string := fieldName asString. "could be the SmallInteger 0; see #testMCRF"
	(instruction internalBindings includesKey: fieldName) ifTrue: [ 
		string := fieldName, '=', (instruction internalBindings at: fieldName) asString ].
	font := self fieldFont: string in: right - left.
	width := font widthOfString: string.
	x := left + right - width // 2.
	aCanvas
		drawString: string 
		at: x @ (self bitBox top + 3)
		font: font
		color: Color black
]

{ #category : #drawing }
InstructionMorph >> drawFieldSeparator: i on: aCanvas [
	"Right vertical separator"
	| right |
	i==32 ifTrue: [ ^self ].
	right := self stumpX: i.
	aCanvas
		line: right @ (self bitBox bottom-1)
		to: right  @ (self bitBox top)
		width: 1
		color: (Color black)
]

{ #category : #drawing }
InstructionMorph >> drawFieldsOn: aCanvas [
	| i |
	i := 0.
	instruction format bitFields do: [ :field |
		| left right |
		left := self stumpX: i.
		i := i + field value abs.
		right := self stumpX: i.
		self
			drawFieldSeparator: i on: aCanvas; 
			drawField: field key on: aCanvas left: left right: right. 
		 ]
]

{ #category : #drawing }
InstructionMorph >> drawNameOn: aCanvas [
	aCanvas
		drawString: instruction nameForInspector
		at: self bounds topLeft 
		font: self nameFont
		color: Color black
]

{ #category : #drawing }
InstructionMorph >> drawOn: aCanvas [
	aCanvas
		clipBy: self bounds
		during: [:clippedCanvas |
			clippedCanvas
				fillRectangle: self bounds
				color: Color white.	
		self
			drawNameOn: clippedCanvas ;
			drawBitGridOn: clippedCanvas ;
			drawFieldsOn: clippedCanvas ;
			drawSemanticsOn: clippedCanvas 

				].
 
]

{ #category : #drawing }
InstructionMorph >> drawSemanticForest: anInstructionSemantic on: aCanvas y: y [
	"Answer how tall it took."
	| height |
	self
		drawCost: anInstructionSemantic cost
		on: aCanvas
		y: y
		hasDelaySlot: anInstructionSemantic hasDelaySlot.

	aCanvas
		"line"
		line: self bitBox left @ y
		to: self bitBox right @ y
		width: 1
		color: (Color red).
	height := 0.
	anInstructionSemantic trees do: [ :semTree |
		height := height + (self drawSemanticTree: semTree on: aCanvas y: y+height) ].
	^22 max: height + 3

]

{ #category : #drawing }
InstructionMorph >> drawSemanticTree: anInstructionSemanticTree on: aCanvas y: y [
	"Answer how tall it took."
	^anInstructionSemanticTree
		drawOn: aCanvas
		at: self bounds left @ (y+2)
]

{ #category : #drawing }
InstructionMorph >> drawSemanticsOn: aCanvas [
	"| semantics y |
	semantics := instruction semantics.
	y := self bitBox bottom + 18.
	semantics do: [ :anInstructionSemantic |
		y := y + (self drawSemanticForest: anInstructionSemantic on: aCanvas y: y) ]" "draw lwisem here"
]

{ #category : #drawing }
InstructionMorph >> drawStump: i on: aCanvas [
	| x |
	x := self stumpX: i.
	aCanvas
		line: x @ (self bitBox bottom-1)
		to: x  @ (self bitBox bottom-(self stumpHeight: i))
		width: 1
		color: (Color red)
]

{ #category : #drawing }
InstructionMorph >> drawSubscript: i on: aCanvas [
	| subscript centerOfCell |
	subscript := (32 - i) asString.
	centerOfCell := (self stumpX: i) - (self bounds width - 2 // 32  // 2).
	self drawStump: i on: aCanvas. 
	aCanvas
		drawString: subscript
		at: (centerOfCell - ((self bitNumberFont widthOfString: subscript)//2)) @ self bitBox bottom
		font: self bitNumberFont
		color: Color blue
]

{ #category : #fonts }
InstructionMorph >> fieldFont: stringToFit in: width [
	| pointSize font |
	pointSize := 10.
	[ font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: pointSize.
	(font widthOfString: stringToFit) < width or: [ pointSize <= 8 ] ] whileFalse: [ pointSize := pointSize - 1 ].
	^font
]

{ #category : #accessing }
InstructionMorph >> instruction [
	^ instruction
]

{ #category : #accessing }
InstructionMorph >> instruction: anObject [
	instruction := anObject
]

{ #category : #fonts }
InstructionMorph >> nameFont [

	| font  |
	font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 14.
	^ font emphasis: TextEmphasis bold emphasisCode
]

{ #category : #fonts }
InstructionMorph >> semanticLogicFont [
	| font  |
	font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 10.
	^ font
]

{ #category : #fonts }
InstructionMorph >> semanticSourceFont [
	| font  |
	font := LogicalFont familyName: 'Bitmap DejaVu Sans' pointSize: 10.
	^ font emphasis: TextEmphasis italic emphasisCode
]

{ #category : #drawing }
InstructionMorph >> stumpHeight: i [
		^ i%4 == 0 ifTrue: [12] ifFalse: [8]
]

{ #category : #drawing }
InstructionMorph >> stumpX: i [
	^ i * self bounds width - 2 // 32 + self bounds left

]
