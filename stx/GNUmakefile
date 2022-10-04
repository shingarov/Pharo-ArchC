PROJECT=ArchC

include GNUmakefile.local

ifndef ARCHC_PDL_DIR
ARCHC_PDL_DIR=../pdl

# Metacello group to load. Technically we're not using
# Metacello in St/X but we use the same variable in StX
# makefile as in Pharo makefile to allow testing against
# MachineArithmetic and BitVector packages
GROUP ?= default

../pdl:
	(cd .. && ./get-pdls.sh)
endif

ifndef MACHINEARITHMETIC_DIR

MACHINEARITHMETIC_DIR=../MachineArithmetic

../MachineArithmetic:
	git clone https://github.com/shingarov/MachineArithmetic $@
endif

all: build

include ../stx.gmk

ifeq ($(GROUP),default)
bitvector_impl=BaselineOfMachineArithmetic
else
 ifeq ($(GROUP),alternative-bitvector)
  bitvector_impl=BaselineOfBitVector
 else
  $(error Invalid GROUP value (must be either 'default' or 'alternative-bitvector'))
 endif
endif

build: $(STX) $(ARCHC_PDL_DIR) $(MACHINEARITHMETIC_DIR)
	@echo "To run Smalltalk/X with $(PROJECT) loaded, run:"
	@echo ""
	@echo "    ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(STX) --package-path .. --package-path $(MACHINEARITHMETIC_DIR) --load BaselineOf$(PROJECT)"
	@echo ""
	@echo "or use shortcut:"
	@echo ""
	@echo "    make run"
	@echo ""


run: $(STX) $(ARCHC_PDL_DIR) $(MACHINEARITHMETIC_DIR)
	ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(STX) \
		--package-path .. \
		--package-path $(MACHINEARITHMETIC_DIR) \
		--load $(bitvector_impl) \
		--load BaselineOf$(PROJECT)

test: $(STX) $(ARCHC_PDL_DIR) $(MACHINEARITHMETIC_DIR)
	ARCHC_PDL_DIR=$(ARCHC_PDL_DIR)/ $(STX) \
		--package-path .. \
		--package-path $(MACHINEARITHMETIC_DIR) \
		--load $(bitvector_impl) \
		--load BaselineOf$(PROJECT) \
		--run Builder::ReportRunner -r Builder::TestReport --fail-on-failure \
			-p BitVector-Tests \
			-p ArchC-Core-Tests \
			-p ArchC-RISCV-Tests

clean:
	rm -rf *Test.xml

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

