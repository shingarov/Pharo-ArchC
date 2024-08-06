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

prereq:: ../pdl/riscv/riscv-opcodes/opcodes-rv32i

../pdl/riscv/riscv-opcodes/opcodes-rv32i:
	git submodule update --init --recursive $(dir $@)

build: prereq
	@echo "To run Smalltalk/X with $(PROJECT) loaded, run:"
	@echo ""
	@echo "    make run"
	@echo ""


run: build
	$(STX) \
		--quick \
		--package-path $(MACHINEARITHMETIC_DIR) \
		--package-path ../src \
		--load BaselineOf$(PROJECT) \

test: build
	$(STX) \
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
