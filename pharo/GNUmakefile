PROJECT=ArchC

include GNUmakefile.local

# Pharo version to use. Currently, only 8.0 is supported,
# Pharo 9.0 and later is known to crash when using Z3.
PHARO_VERSION ?= 80

all: $(PROJECT).image

ifndef ARCHC_PDL_DIR
ARCHC_PDL_DIR=../pdl

../pdl:
	(cd .. && ./get-pdls.sh)
endif

include ../pharo.gmk

$(PROJECT).image: $(PHARO_VM) $(PHARO_IMAGE) ../src/*/*.st $(ARCHC_PDL_DIR)
	$(PHARO_VM_HEADLESS) $(PHARO_IMAGE) save $(shell pwd)/$(PROJECT)
ifdef MACHINEARITHMETIC_DIR
	$(PHARO_VM_HEADLESS) $@ eval --save "(IceRepositoryCreator new location: '$(MACHINEARITHMETIC_DIR)/' asFileReference; createRepository) register" || rm $@
	$(PHARO_VM_HEADLESS) $@ metacello install tonel://$(MACHINEARITHMETIC_DIR)/ BaselineOfMachineArithmetic || rm $@
endif
	$(PHARO_VM_HEADLESS) $@ eval --save "(IceRepositoryCreator new location: '..' asFileReference; createRepository) register" || rm $@
	$(PHARO_VM_HEADLESS) $@ eval --save "Metacello new baseline: '$(PROJECT)'; repository: 'tonel://../src'; onConflictUseLoaded; load." || rm $@
	@echo ""
	@echo "To open Pharo $(PROJECT) image run:"
	@echo ""
	@echo "    ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(PHARO_VM) $(PROJECT).image"
	@echo ""



test: $(PROJECT).image $(PHARO_VM)
	#$(PHARO_VM_HEADLESS) $< test --fail-on-failure "$(PROJECT).*Tests.*"
	ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(PHARO_VM_HEADLESS) $< test --fail-on-failure "ArchC-Core-Tests" "ArchC-RISCV-Tests"

clean:
	rm -f $(PROJECT).image $(PROJECT).changes *Test.xml *.fuel
	rm -fr pharo-local

mrproper:: clean

GNUmakefile.local::
		@echo "# Local tunables. There's no need to change anything," >> $@
		@echo "# suitable defaults are provided." >> $@
		@echo "" >> $@
		@echo "# To load MachineArithmetic from local directory, set MACHINEARITHMETIC_DIR" >> $@
		@echo "# variable to directory where MachineArithmetic is cloned. If unset (default)" >> $@
		@echo "# it will be fetched by Metacello as defined in ../src/BaselineOfArchC/BaselineOfArchC.class.st" >> $@
		@echo "# MACHINEARITHMETIC_DIR=../../MachineArithmetic" >> $@
		@echo "" >> $@
		@echo "# To specify custom directory with PDLs, set ARCHC_PDL_DIR" >> $@
		@echo "# variable to directory with PDLs. If unset (default)" >> $@
		@echo "# it will be fetched by 'get-pdls.sh' script." >> $@
		@echo "# ARCHC_PDL_DIR=../pdl" >> $@
		@echo "" >> $@
