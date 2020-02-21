Class {
	#name : #AccGenInstructionSemanticTree,
	#superclass : #Object,
	#instVars : [
		'source',
		'instruction',
		'term',
		'let'
	],
	#category : #'ArchC-Core'
}

{ #category : #'instance creation' }
AccGenInstructionSemanticTree class >> let: let in: source [
	^self new 
		let: let;
		source: source;
		yourself
]

{ #category : #drawing }
AccGenInstructionSemanticTree >> drawLogicOn: aCanvas at: origin [
	"Answer how tall it took."
	| logicStream morph |
	logicStream := WriteStream on: String new.
	self printLogicOn: logicStream.
	morph := TextMorph new
		contents: (logicStream contents);
		fontName: 'Bitmap DejaVu Sans' pointSize: 10;
		backgroundColor: (Color white);
		wrapFlag: true;
		bounds: (origin extent: 550@500);
		enabled: true;
		autoFit: true.
		aCanvas drawMorph: morph.
	^morph bounds extent y
]

{ #category : #drawing }
AccGenInstructionSemanticTree >> drawOn: aCanvas at: origin [
	"Answer how tall it took."
	| sourceHeight |
	sourceHeight := self drawSourceOn: aCanvas at: origin.
	^sourceHeight + (self drawLogicOn: aCanvas at: origin + (0@sourceHeight)).
	
]

{ #category : #drawing }
AccGenInstructionSemanticTree >> drawSourceOn: aCanvas at: origin [
	"Answer how tall it took."
	| morph |
	morph := TextMorph new
		contents: source;
		fontName: 'Bitmap DejaVu Sans' pointSize: 12;
		backgroundColor: (Color white);
		wrapFlag: true;
		bounds: (origin extent: 500@500);
		enabled: true;
		autoFit: true.
	aCanvas drawMorph: morph.
	^morph bounds extent y
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> instruction [
	^ instruction
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> instruction: backPtrToInstruction [
	instruction := backPtrToInstruction
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> let [
	^ let
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> let: anObject [
	let := anObject
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printLetOn: aStream [
	let keysAndValuesDo: [ :k :v |
		aStream
			nextPutAll: '  Op';
			nextPutAll: (k printString);
			nextPutAll: ' = '.
		v putOn: aStream.
		aStream
			nextPut: $,;
			cr ]
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printLogicOn: aStream [
	term printRewriteHeadOn: aStream.
	aStream nextPutAll: ' => ';
		nextPutAll: instruction name;
		nextPut: $(.
	self printOperandNumbersOn: aStream.
	aStream
		nextPut: $);
		nextPutAll: ' :-';
		lf.
	self printLetOn: aStream.
	term printConditionsOn: aStream instruction: instruction.
	aStream nextPutAll: '  true.'
]

{ #category : #logic }
AccGenInstructionSemanticTree >> printOperandNumbersOn: aStream [
	| operandNumbers  |
	operandNumbers := (term addOperandNumbersTo: let keys asSet) sorted collect: [ :n | 'Op', n printString ].
	operandNumbers printUsing: #putOn: on: aStream
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> source [
	^ source
]

{ #category : #accessing }
AccGenInstructionSemanticTree >> source: anObject [
	source := anObject.
	term := AcSemanticTermParser new parse: source.
]
