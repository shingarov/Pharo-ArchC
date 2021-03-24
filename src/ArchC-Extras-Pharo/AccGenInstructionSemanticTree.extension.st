Extension { #name : #AccGenInstructionSemanticTree }

{ #category : #'*ArchC-Extras-Pharo' }
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

{ #category : #'*ArchC-Extras-Pharo' }
AccGenInstructionSemanticTree >> drawOn: aCanvas at: origin [
	"Answer how tall it took."
	| sourceHeight |
	sourceHeight := self drawSourceOn: aCanvas at: origin.
	^sourceHeight + (self drawLogicOn: aCanvas at: origin + (0@sourceHeight)).
	
]

{ #category : #'*ArchC-Extras-Pharo' }
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
