Class {
	#name : #SailCodePresentation,
	#superclass : #GLMRubricSmalltalkCodePresentation,
	#category : #Isla
}

{ #category : #examples }
SailCodePresentation class >> pharoMethodPresentationExample [
	"
	self pharoMethodPresentationExample
	"
	
	| browser |
	browser := GLMTabulator new.
	browser
		row: #r1;
		row: #r2.
	browser transmit
		to: #r1;
		andShow: [ :aComposite | aComposite pharoMethod display: [ :method | method sourceCode ] ].
	browser transmit
		to: #r2;
		andShow: [ :aComposite | 
					aComposite pharoMethod
						display: [ :method | method sourceCode ];
						smalltalkClass: [ :method | method methodClass ] ].
	browser openOn: CompiledMethod class >> #gtExampleSimple
]

{ #category : #formatting }
SailCodePresentation >> formatSourceCode [
	self announce: GLMFormatCode.
]

{ #category : #rendering }
SailCodePresentation >> renderGlamorouslyOn: aRenderer [ 
	self registerAnnouncements.
	^ GLMMorphicPharoMethodRenderer render: self from: aRenderer
]
