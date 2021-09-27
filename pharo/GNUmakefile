PROJECT=ArchC

include GNUMakefile.local

all: pharo-ui $(PROJECT).image

pharo pharo-ui Pharo.image:
	curl https://get.pharo.org/64/80+vm | bash

$(PROJECT).image: pharo Pharo.image ../src ../pdl/arm GNUMakefile.local
	./pharo Pharo.image save $(PROJECT)
ifdef MACHINEARITHMETIC_DIR
	./pharo $@ eval --save "(IceRepositoryCreator new location: '$(MACHINEARITHMETIC_DIR)/' asFileReference; createRepository) register" || rm $@
	./pharo $@ metacello install tonel://$(MACHINEARITHMETIC_DIR)/ BaselineOfMachineArithmetic || rm $@
endif
	./pharo $@ eval --save "(IceRepositoryCreator new location: '..' asFileReference; createRepository) register" || rm $@
	./pharo $@ eval --save "Metacello new baseline: '$(PROJECT)'; repository: 'tonel://../src'; onConflictUseLoaded; load." || rm $@
	@echo ""
	@echo "To open Pharo $(PROJECT) image run:"
	@echo ""
	@echo "    ./pharo-ui $(PROJECT).image"
	@echo ""

../pdl/arm:
	(cd .. && ./get-pdls.sh)

test: $(PROJECT).image pharo
	#./pharo $< test --fail-on-failure "$(PROJECT).*Tests.*"
	./pharo $< test --fail-on-failure "ArchC-Core-Tests" "ArchC-RISCV-Tests"

clean:
	rm -f $(PROJECT).image $(PROJECT).changes *Test.xml *.fuel
	rm -fr pharo-local

mrproper: clean
	rm -rf Pharo* pharo* icon-packs

GNUMakefile.local:
		@echo "# Local tunables. There's no need to change anything," >> $@
		@echo "# suitable defaults are provided." >> $@
		@echo "" >> $@
		@echo "# To load MachineArithmetic from local directory, set MACHINEARITHMETIC_DIR" >> $@
		@echo "# variable to directory where MachineArithmetic is cloned. If unset (default)" >> $@
		@echo "# it will be fetched by Metacello as defined in ../src/BaselineOfArchC/BaselineOfArchC.class.st" >> $@
		@echo "# MACHINEARITHMETIC_DIR=../../MachineArithmetic" >> $@
		@echo "" >> $@
