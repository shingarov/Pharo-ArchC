PROJECT=ArchC

all: build

../makefiles/%.gmk:
	git submodule update --init --recursive $(dir $@)

-include GNUmakefile.local
include ../makefiles/stx.gmk
include ../makefiles/git.gmk

ifndef MACHINEARITHMETIC_DIR
MACHINEARITHMETIC_DIR    := ../3rdparty/MachineArithmetic
MACHINEARITHMETIC_URL    ?= https://github.com/shingarov/MachineArithmetic
MACHINEARITHMETIC_BRANCH ?= pure-z3
$(eval $(call git-clone-local,MACHINEARITHMETIC_DIR,$(MACHINEARITHMETIC_URL),$(MACHINEARITHMETIC_BRANCH)))
endif

ifndef ARCHC_PDL_DIR
ARCHC_PDL_DIR    := ../pdl
ARCHC_PDL_URL    ?= https://github.com/janvrany/Pharo-ArchC-PDL.git
ARCHC_PDL_BRANCH ?= master
$(eval $(call git-clone-local,ARCHC_PDL_DIR,$(ARCHC_PDL_URL),$(ARCHC_PDL_BRANCH)))
endif

build: prereq
	@echo "To run Smalltalk/X with $(PROJECT) loaded, run:"
	@echo ""
	@echo "    make run"
	@echo ""


run: build
	ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(STX) \
		--quick \
		--package-path $(MACHINEARITHMETIC_DIR) \
		--package-path ../src \
		--load BaselineOf$(PROJECT) \

test: build
	ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(STX) \
		--package-path $(MACHINEARITHMETIC_DIR) \
		--package-path ../src \
		--load BaselineOf$(PROJECT) \
		--run Builder::ReportRunner -r Builder::TestReport --fail-on-failure \
			-p "ArchC-Core-Tests" \
			-p "ArchC-RISCV-Tests" \
			-p "ArchC-DSL-Tests"

clean::

mrproper:: clean

.PHONY: all build run test clean mrproper
