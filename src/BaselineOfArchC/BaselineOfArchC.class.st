Class {
	#name : #BaselineOfArchC,
	#superclass : #BaselineOf,
	#category : #BaselineOfArchC
}

{ #category : #baselines }
BaselineOfArchC >> baseline: spec [
	<baseline>
	spec
		for: #pharo
		do: [ 
			spec baseline: 'PetitParser' with: [
				spec loads: 'Core'. 
				spec loads: 'Analyzer'. 
	   		spec repository: 'github://moosetechnology/PetitParser' 
			].
		
			spec baseline: 'MachineArithmetic' with: [
				spec repository: 'github://shingarov/MachineArithmetic:pure-z3'
			].
		
			spec
				package: #'ArchC-Core' with:[spec requires: 'PetitParser'];
				package: #'ArchC-Core-Tests';
				package: #'ArchC-Extras-Pharo';
				package: #'ArchC-Extras-Pharo-Tests'.
		]
]
