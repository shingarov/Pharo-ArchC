/**
 * @file      arm_isa_helper.H
 * @author    Rafael Auler 
 *
 *            The ArchC Team
 *            http://www.archc.org/
 *
 *            Computer Systems Laboratory (LSC)
 *            IC-UNICAMP
 *            http://www.lsc.ic.unicamp.br/
 *
 * @version   1.0
 * @date      Apr 2012
 * 
 * @brief     This is a helper header file included directly
 *            in the generated arm_isa.H file. Here we put
 *            data structures and functions used throughout
 *            the arm_isa.cpp (arm instruction behaviors).
 * 
 * @attention Copyright (C) 2002-2012 --- The ArchC Team
 *
 */

// Abstracts away the different ARM processor modes
class processor_mode {
public:
	static const unsigned int USER_MODE       = 0x10; // 0b10000;
	static const unsigned int FIQ_MODE        = 0x11; // 0b10001;
	static const unsigned int IRQ_MODE        = 0x12; // 0b10010;
	static const unsigned int SUPERVISOR_MODE = 0x13; // 0b10011;
	static const unsigned int ABORT_MODE      = 0x17; // 0b10111;
	static const unsigned int UNDEFINED_MODE  = 0x1B; // 0b11011;
	static const unsigned int SYSTEM_MODE     = 0x1F; // 0b11111;
	static const unsigned int MODE_MASK       = 0x1F; // 0b11111;
  
	bool fiq, irq, thumb;
	unsigned int mode;
  
	// Initializes with:
	// FIQ enabled  (CPSR FIQ disable bit set = false)
	// IRQ enabled
	// Thumb disabled
	// User mode
  processor_mode() : fiq(false), irq(false), thumb(false), mode (USER_MODE) {}
};

enum exception_type {
	EXCEPTION_RESET, EXCEPTION_UNDEFINED_INSTR,  EXCEPTION_SWI, 
	EXCEPTION_PREFETCH_ABORT, EXCEPTION_DATA_ABORT, EXCEPTION_IRQ,
	EXCEPTION_FIQ
};

processor_mode arm_proc_mode;

// Useful abstract data types defining ARM flags and register access
typedef struct flag_s {
	bool N; // Negative
	bool Z; // Zero
	bool C; // Carry
	bool V; // Overflow
	bool Q; // DSP
	bool T; // Thumb
} flag_t;

typedef union {
	int8_t byte[4];
	int32_t entire;
} reg_t;

typedef union {
	int32_t reg[2];
	int64_t hilo;
} r64bit_t;

// Global instances used throughout the model.
flag_t flags;
bool execute;

reg_t dpi_shiftop;
bool dpi_shiftopcarry;

reg_t ls_address;
reg_t lsm_startaddress;
reg_t lsm_endaddress;

reg_t OP1;
reg_t OP2;

// When rn is in rlist. e.g: push {sp, ...}
reg_t lsm_oldrn;


// Functions used to determine which register to access
// in case of using other processor modes
void bypass_write(unsigned address, unsigned datum) {
  if (arm_proc_mode.mode == processor_mode::USER_MODE ||
      arm_proc_mode.mode == processor_mode::SYSTEM_MODE) {
    RB.write(address, datum);
    return;
  }
  switch (arm_proc_mode.mode) {
  case processor_mode::FIQ_MODE:
    switch (address) {
    case 14:
      R14_fiq = datum;
      break;
    case 13:
      R13_fiq = datum;
      break;
    case 12:
      R12_fiq = datum;
      break;
    case 11:
      R11_fiq = datum;
      break;
    case 10:
      R10_fiq = datum;
      break;
    case 9:
      R9_fiq = datum;
      break;
    case 8:
      R8_fiq = datum;
      break;
    default:
      RB .write(address, datum);
      break;
    }
    break;
  case processor_mode::IRQ_MODE:
    if (address == 14)
      R14_irq = datum;
    else if (address == 13)
      R13_irq = datum;
    else
      RB .write(address, datum);
    break;
  case processor_mode::SUPERVISOR_MODE:
    if (address == 14)
      R14_svc = datum;
    else if (address == 13)
      R13_svc = datum;
    else
      RB .write(address, datum);
    break;
  case processor_mode::ABORT_MODE:
    if (address == 14)
      R14_abt = datum;
    else if (address == 13)
      R13_abt = datum;
    else
      RB .write(address, datum);
    break;
  case processor_mode::UNDEFINED_MODE:
    if (address == 14)
      R14_und = datum;
    else if (address == 13)
      R13_und = datum;
    else
      RB .write(address, datum);
    break;
  }
}

unsigned bypass_read(unsigned address) {
  if (arm_proc_mode.mode == processor_mode::USER_MODE ||
      arm_proc_mode.mode == processor_mode::SYSTEM_MODE)
    return RB .read(address);
  switch (arm_proc_mode.mode) {
  case processor_mode::FIQ_MODE:
    switch (address) {
    case 14:
      return R14_fiq;
      break;
    case 13:
      return R13_fiq;
      break;
    case 12:
      return R12_fiq;
      break;
    case 11:
      return R11_fiq;
      break;
    case 10:
      return R10_fiq;
      break;
    case 9:
      return R9_fiq;
      break;
    case 8:
      return R8_fiq;
      break;
    default:
      return RB.read(address);
      break;
    }
    break;
  case processor_mode::IRQ_MODE:
    if (address == 14)
      return R14_irq;
    else if (address == 13)
      return R13_irq;
    else
      return RB.read(address);
    break;
  case processor_mode::SUPERVISOR_MODE:
    if (address == 14)
      return R14_svc;
    else if (address == 13)
      return R13_svc;
    else
      return RB.read(address);
    break;
  case processor_mode::ABORT_MODE:
    if (address == 14)
      return R14_abt;
    else if (address == 13)
      return R13_abt;
    else
      return RB.read(address);
    break;
  case processor_mode::UNDEFINED_MODE:
    if (address == 14)
      return R14_und;
    else if (address == 13)
      return R13_und;
    else
      return RB.read(address);
    break;
  }
  return ~((unsigned)0);
}

//! User defined macros to access a single bit
#define isBitSet(variable, position) (((variable & (1 << (position))) != 0) ? true : false) 
#define getBit(variable, position) (((variable & (1 << (position))) != 0) ? true : false)
#define setBit(variable, position) variable = variable | (1 << (position))
#define clearBit(variable, position) variable = variable & (~(1 << (position)))

//! Useful functions to easily describe arm instructions behavior
static inline reg_t ArithmeticShiftRight(int shiftamount, reg_t reg) {
  reg_t tmp = reg;
  tmp.entire = ((int32_t)tmp.entire) >> shiftamount;
  return tmp;
}

static inline reg_t RotateRight(int shiftamount, reg_t reg) {
  reg_t ret;
  ret.entire = (((uint32_t)reg.entire) >> shiftamount) | (((uint32_t)reg.entire) << (32 - shiftamount));
  return ret;
}

static inline int32_t SignExtend(int32_t word, int word_length) {
  const int32_t m = 1U << (word_length - 1);
  int32_t x = (word) & ((1ULL << word_length) - 1);
  return ((x ^ m) - m);
}

static inline int LSM_CountSetBits(reg_t registerList) {
  int i, count;
	
  count = 0;
  for (i=0; i<16; i++) { // Verify limits for big/little endian
    if (isBitSet(registerList.entire,i)) count++;
  }
  return count;
}

inline reg_t CPSRBuild() {
  reg_t CPSR;
	
  CPSR.entire = arm_proc_mode.mode;
  if (arm_proc_mode.fiq)
    setBit(CPSR.entire,6); // FIQ disable
  if (arm_proc_mode.irq)
    setBit(CPSR.entire,7); // IRQ disable
  if (arm_proc_mode.thumb)
    setBit(CPSR.entire,5); // Thumb
  if (flags.N) setBit(CPSR.entire,31); // N flag
  else clearBit(CPSR.entire,31);
  if (flags.Z) setBit(CPSR.entire,30); // Z flag
  else clearBit(CPSR.entire,30);
  if (flags.C) setBit(CPSR.entire,29); // C flag
  else clearBit(CPSR.entire,29);
  if (flags.V) setBit(CPSR.entire,28); // V flag
  else clearBit(CPSR.entire,28);
  if (flags.Q) setBit(CPSR.entire,27); // Q flag
  else clearBit(CPSR.entire,27);
  if (flags.T) setBit(CPSR.entire, 5); // T flag
	
  return CPSR;
}

uint32_t readCPSR() {
  return (uint32_t) CPSRBuild().entire;
}

void writeCPSR(unsigned value) {
  reg_t CPSR;
	
  CPSR.entire = value;
  flags.N = (getBit(CPSR.entire,31))? true : false;
  flags.Z = (getBit(CPSR.entire,30))? true : false;
  flags.C = (getBit(CPSR.entire,29))? true : false;
  flags.V = (getBit(CPSR.entire,28))? true : false;
  flags.Q = (getBit(CPSR.entire,27))? true : false;
  flags.T = (getBit(CPSR.entire,5))? true : false;
  arm_proc_mode.fiq = getBit(CPSR.entire,6)? true : false;
  arm_proc_mode.irq = getBit(CPSR.entire,7)? true : false;
  arm_proc_mode.mode = value & processor_mode::MODE_MASK;    
}

// This function implements the transfer of the SPSR of the current processor
// mode to the CPSR, usually executed when exiting from an exception handler.
void SPSRtoCPSR() {
  switch (arm_proc_mode.mode) {
  case processor_mode::FIQ_MODE:
    writeCPSR(SPSR_fiq);
    break;
  case processor_mode::IRQ_MODE:
    writeCPSR(SPSR_irq);
    break;
  case processor_mode::SUPERVISOR_MODE:
    writeCPSR(SPSR_svc);
    break;
  case processor_mode::ABORT_MODE:
    writeCPSR(SPSR_abt);
    break;
  case processor_mode::UNDEFINED_MODE:
    writeCPSR(SPSR_und);
    break;
  default:
    printf("Invalid processor mode.\n");
    return;
  }
}

void writeSPSR(unsigned value) {
  switch (arm_proc_mode.mode) {
  case processor_mode::FIQ_MODE:
    SPSR_fiq = value;
    break;
  case processor_mode::IRQ_MODE:
    SPSR_irq = value;
    break;
  case processor_mode::SUPERVISOR_MODE:
    SPSR_svc = value;
    break;
  case processor_mode::ABORT_MODE:
    SPSR_abt = value;
    break;
  case processor_mode::UNDEFINED_MODE:
    SPSR_und = value;
    break;
  }
}

unsigned readSPSR() {
  switch (arm_proc_mode.mode) {
  case processor_mode::FIQ_MODE:
    return SPSR_fiq;
  case processor_mode::IRQ_MODE:
    return SPSR_irq;
  case processor_mode::SUPERVISOR_MODE:
    return SPSR_svc;
  case processor_mode::ABORT_MODE:
    return SPSR_abt;
  case processor_mode::UNDEFINED_MODE:
    return SPSR_und;
  }
  return 0;
}

bool in_a_privileged_mode() {
  switch (arm_proc_mode.mode) {
  case processor_mode::SYSTEM_MODE:
  case processor_mode::FIQ_MODE:
  case processor_mode::IRQ_MODE:
  case processor_mode::SUPERVISOR_MODE:
  case processor_mode::ABORT_MODE:
  case processor_mode::UNDEFINED_MODE:
    return true;
  }  
  return false;
}

const char * cur_mode_str() {
  switch (arm_proc_mode.mode) {
  case processor_mode::SYSTEM_MODE:
    return "SYSTEM";
  case processor_mode::USER_MODE:
    return "USER";
  case processor_mode::FIQ_MODE:
    return "FIQ";
  case processor_mode::IRQ_MODE:
    return "IRQ";
  case processor_mode::SUPERVISOR_MODE:
    return "SUPERVISOR";
  case processor_mode::ABORT_MODE:
    return "ABORT";
  case processor_mode::UNDEFINED_MODE:
    return "UNDEFINED";
  }
  return 0;
}


// Exception vector addresses
static const unsigned int RESET_ADDR             = 0x00000000; 
static const unsigned int RESET_ADDR_HI          = 0xffff0000; 
static const unsigned int UNDEFINED_ADDR         = 0x00000004; 
static const unsigned int UNDEFINED_ADDR_HI      = 0xffff0004; 
static const unsigned int SWI_ADDR               = 0x00000008; 
static const unsigned int SWI_ADDR_HI            = 0xffff0008; 
static const unsigned int PREFETCH_ABORT_ADDR    = 0x0000000c; 
static const unsigned int PREFETCH_ABORT_ADDR_HI = 0xffff000c; 
static const unsigned int DATA_ABORT_ADDR        = 0x00000010; 
static const unsigned int DATA_ABORT_ADDR_HI     = 0xffff0010; 
static const unsigned int IRQ_ADDR               = 0x00000018; 
static const unsigned int IRQ_ADDR_HI            = 0xffff0018; 
static const unsigned int FIQ_ADDR               = 0x0000001c; 
static const unsigned int FIQ_ADDR_HI            = 0xffff001c; 

// Whoever calls this interrupt, it must enforce correct exception priority,
// since we can't enforce this here. We simply service the first one to call
// this method. The correct exception priority is:
// Highest    1   Reset (async)
//            2   Data abort (async)
//            3   FIQ (instruction boundaries)
//            4   IRQ (instruction boundaries)
//            5   Prefetch abort (async)
// Lowest     6   Undefined instruction (async)
//                SWI (sync)

// Interrupt handler behavior for interrupt port inta.
void service_interrupt(unsigned excep_type) {
  unsigned cpsr = readCPSR();
	
  // FIQ disabled?
  if ((cpsr & (1 << 6)) && excep_type == EXCEPTION_FIQ)
    return;
	
  // IRQ disabled?
  if ((cpsr & (1 << 7)) && excep_type == EXCEPTION_IRQ)
    return;
	
  switch(excep_type) {
  case EXCEPTION_RESET:
    R14_svc = 0;
    SPSR_svc = 0;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::SUPERVISOR_MODE;
    cpsr = cpsr | (1 << 6); // disable FIQ
#ifdef HIGH_VECTOR
    ac_pc = RESET_ADDR_HI;
#else
    ac_pc = RESET_ADDR;
#endif
    break;
  case EXCEPTION_UNDEFINED_INSTR:
    R14_und = ac_pc; // address of the next instruction after the undef
                             // instruction. we expect this to run only after a
                             // cycle of archc behavioral simulation has been
                             // completed, because ac_pc is set with pc+4
                             // in the end of each cycle.
    SPSR_und = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::UNDEFINED_MODE;
#ifdef HIGH_VECTOR
    ac_pc = UNDEFINED_ADDR_HI;
#else
    ac_pc = UNDEFINED_ADDR;
#endif
    break;
  case EXCEPTION_SWI:
    R14_svc = ac_pc;  // remember ac_pc is pc+4 at each end of cycle
    SPSR_svc = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::SUPERVISOR_MODE;
#ifdef HIGH_VECTOR
    ac_pc = SWI_ADDR_HI;
#else
    ac_pc = SWI_ADDR;
#endif
    break;
  case EXCEPTION_PREFETCH_ABORT:
    R14_abt = ac_pc;  // remember ac_pc is pc+4 at each end of cycle
    SPSR_abt = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::ABORT_MODE;
#ifdef HIGH_VECTOR
    ac_pc = PREFETCH_ABORT_ADDR_HI;
#else
    ac_pc = PREFETCH_ABORT_ADDR;
#endif
    break;
  case EXCEPTION_DATA_ABORT:
    R14_abt = ac_pc + 4;  // remember ac_pc is pc+4 at each end of 
                                  // cycle data aborts sets R14_abt to pc+8
    SPSR_abt = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::ABORT_MODE;
#ifdef HIGH_VECTOR
    ac_pc = DATA_ABORT_ADDR_HI;
#else
    ac_pc = DATA_ABORT_ADDR;
#endif
    break;
  case EXCEPTION_IRQ:
    R14_irq = ac_pc + 4;  // remember ac_pc is pc+4 at each end of cycle
                                  // or the address of a branch target.
                                  // irq sets R14_irq to next instruction to be
                                  // executed +4
    SPSR_irq = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::IRQ_MODE;
#ifdef HIGH_VECTOR
    ac_pc = IRQ_ADDR_HI;
#else
    ac_pc = IRQ_ADDR;
#endif
    break;
  case EXCEPTION_FIQ:
    R14_fiq = ac_pc + 4;  // remember ac_pc is pc+4 at each end of cycle
                                  // or the address of a branch target.
                                  // irq sets R14_irq to next instruction to be
                                  // executed +4
    SPSR_fiq = cpsr;
    cpsr = cpsr & ~processor_mode::MODE_MASK;
    cpsr = cpsr | processor_mode::FIQ_MODE;
    cpsr = cpsr | (1 << 6); // disable FIQ
#ifdef HIGH_VECTOR
    ac_pc = FIQ_ADDR_HI;
#else
    ac_pc = FIQ_ADDR;
#endif
    break;
  default:
    assert(0 && "Unknown interrupt type!");
    abort();
    break;
  }
  cpsr = cpsr & ~(1 << 5); // execute in ARM state
  cpsr = cpsr | (1 << 7); // disable normal interrupts
	
  writeCPSR(cpsr);
}

// Support functions used in arm_isa.cpp to avoid code repetition

void ADD(int rd, int rn, bool s);
void ADC(int rd, int rn, bool s);
void AND(int rd, int rn, bool s);
void B(int h, int offset);
void BX(int rm);
void BIC(int rd, int rn, bool s);
void CDP();
void CLZ(int rd, int rm);
void CMN(int rn);
void CMP(int rn);
void EOR(int rd, int rn, bool s);
void LDC();
void LDM(int rlist, bool r);
void LDR(int rd, int rn);
void LDRB(int rd, int rn);
void LDRBT(int rd, int rn);
void LDRD(int rd, int rn);
void LDRH(int rd, int rn);
void LDRSB(int rd, int rn);
void LDRSH(int rd, int rn);
void LDRT(int rd, int rn);
void MCR();
void MLA(int rd, int rn, int rm, int rs, bool s);
void MOV(int rd, bool s);
void MRC();
void MRS(int rd, bool r, int zero3, int subop2, int func2, int subop1, int rm,
         int field);
void MUL(int rd, int rm, int rs, bool s);
void MVN(int rd, bool s);
void ORR(int rd, int rn, bool s);
void RSB(int rd, int rn, bool s);
void RSC(int rd, int rn, bool s);
void SBC(int rd, int rn, bool s);
void SMLAL(int rdhi, int rdlo, int rm, int rs, bool s);
void SMULL(int rdhi, int rdlo, int rm, int rs, bool s);
void STC();
void STM(int rn, int rlist, unsigned r);
void STR(int rd, int rn);
void STRB(int rd, int rn);
void STRBT(int rd, int rn);
void STRD(int rd, int rn);
void STRH(int rd, int rn);
void STRT(int rd, int rn);
void SUB(int rd, int rn, bool s);
void SWP(int rd, int rn, int rm);
void SWPB(int rd, int rn, int rm);
void TEQ(int rn);
void TST(int rn);
void UMLAL(int rdhi, int rdlo, int rm, int rs, bool s);
void UMULL(int rdhi, int rdlo, int rm, int rs, bool s);
void DSMLA(int rd, int rn);
void DSMUL(int rd);

