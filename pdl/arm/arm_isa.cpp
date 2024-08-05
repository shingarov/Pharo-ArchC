/**
 * @file      arm_isa.cpp
 * @author    Danilo Marcolin Caravana
 *            Rafael Auler
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
 * @brief     The ArchC ARMv5e functional model.
 * 
 * @attention Copyright (C) 2002-2012 --- The ArchC Team
 *
 */

#include "arm_isa.H"
#include "arm_isa_init.cpp"
#include "arm_bhv_macros.H"
#include <stdint.h> // define types uint32_t, etc

using namespace arm_parms;

#define DEFAULT_STACK_SIZE (512 * 1024)
static int processors_started = 0;

//If you want debug information for this model, uncomment next line
//#define DEBUG_MODEL

//If you want the processor to operate in system model instead
//of user model, uncomment next line
//#define SYSTEM_MODEL

//This is a switch to turn unpredictable behavior for some
//instructions to be silently ignored. This is necessary for
//some gcc generated ARM user level code.
#define FORGIVE_UNPREDICTABLE

// If FORGIVE_UNPREDITABLE is turned on, necessarily turns off
// SYSTEM_MODEL, since the system model cannot work with this flag.
#ifdef FORGIVE_UNPREDITABLE
#undef SYSTEM_MODEL
#endif

#ifdef DEBUG_MODEL
#include <stdarg.h>

static inline int dprintf(const char *format, ...) {
  int ret;
  va_list args;
  va_start(args, format);
  ret = vfprintf(ac_err, format, args);
  va_end(args);
  return ret;
}
#else
inline void dprintf(const char *format, ...) {}
#endif

//! User defined macros to reference registers
#define LR 14 // link return
#define PC 15 // program counter

#ifdef SYSTEM_MODEL
#define RB_write bypass_write
#define RB_read bypass_read
#else
#define RB_write RB.write
#define RB_read RB.read
#endif

#ifdef SLEEP_AWAKE_MODE
/*********************************************************************************/
/* SLEEP / AWAKE mode control                                                    */
/* INTR_REG may store 1 (AWAKE MODE) or 0 (SLEEP MODE)                           */
/* if intr_reg == 0, the simulator will be suspended until it receives a         */   
/* interruption 1                                                                */    
/*********************************************************************************/
#define test_sleep() { if (intr_reg.read() == 0) ac_wait();  }
#else
#define test_sleep() {}
#endif

void ac_behavior( begin ) {
#ifdef SYSTEM_MODEL
  arm_proc_mode.mode = processor_mode::SUPERVISOR_MODE;
  arm_proc_mode.thumb = false;
  arm_proc_mode.fiq = false;
  arm_proc_mode.irq = false;
  ac_pc = 0;
#endif
  // Initializing flags and model variables
  flags.Z = false;
  flags.C = false;
  flags.N = false; 
  flags.V = false;
  flags.Q = false;
  flags.T = false;
  execute = false;
  dpi_shiftop.entire = 0;
  dpi_shiftopcarry = false;
  ls_address.entire = 0;
  lsm_startaddress.entire = 0;
  lsm_endaddress.entire = 0;
  OP1.entire = 0;
  OP2.entire = 0;

  RB.write(13, AC_RAM_END - 1024 - processors_started++ * DEFAULT_STACK_SIZE);
}

//!Generic instruction behavior method.
void ac_behavior( instruction ) {

   test_sleep();

  dprintf("-------------------- PC=%#x -------------------- %lld\n", (uint32_t)ac_pc, ac_instr_counter);

  // Conditionally executes instruction based on COND field, common to all ARM instructions.
  execute = false;

  switch(cond) {
    case  0: if (flags.Z == true) execute = true; break;
    case  1: if (flags.Z == false) execute = true; break;
    case  2: if (flags.C == true) execute = true; break;
    case  3: if (flags.C == false) execute = true; break;
    case  4: if (flags.N == true) execute = true; break;
    case  5: if (flags.N == false) execute = true; break; 
    case  6: if (flags.V == true) execute = true; break;
    case  7: if (flags.V == false) execute = true; break; 
    case  8: if ((flags.C == true)&&(flags.Z == false)) execute = true; break; 
    case  9: if ((flags.C == false)||(flags.Z == true)) execute = true; break;
    case 10: if (flags.N == flags.V) execute = true; break;
    case 11: if (flags.N != flags.V) execute = true; break; 
    case 12: if ((flags.Z == false)&&(flags.N == flags.V)) execute = true; break;
    case 13: if ((flags.Z == true)||(flags.N != flags.V)) execute = true;  break;
    case 14: execute = true; break;
    default: execute = false;
  }

  // PC increment
  ac_pc += 4;
  RB_write(PC, ac_pc);

  if(!execute) {
    dprintf("cond=0x%X\n", cond);
    dprintf("Instruction will not be executed due to condition flags.\n");
    ac_annul();
  }
}
 
// Instruction Format behavior methods.

//!DPI1 - Second operand is register with imm shift
void ac_behavior( Type_DPI1 ) {

  arm_isa::reg_t RM2;

  // Special case: rm = 15
  if (rm == 15) {
    // PC is already incremented by four, so only add 4 again (not 8)
    RM2.entire = RB_read(rm) + 4;
  }
  else RM2.entire = RB_read(rm);
      
  switch(shift) {
  case 0: // Logical shift left
    if ((shiftamount >= 0) && (shiftamount <= 31)) {
      if (shiftamount == 0) {
	dpi_shiftop.entire = RM2.entire;
	dpi_shiftopcarry = flags.C;
      } else {
	dpi_shiftop.entire = RM2.entire << shiftamount;
	dpi_shiftopcarry = getBit(RM2.entire, 32 - shiftamount);
      }
    }
    break;
  case 1: // Logical shift right
    if ((shiftamount >= 0) && (shiftamount <= 31)) {
      if (shiftamount == 0) {
	dpi_shiftop.entire = 0;
	dpi_shiftopcarry = getBit(RM2.entire, 31);
      } else {
	dpi_shiftop.entire = ((uint32_t) RM2.entire) >> shiftamount;
	dpi_shiftopcarry = getBit(RM2.entire, shiftamount - 1);
      }
    }
    break;
  case 2: // Arithmetic shift right
    if ((shiftamount >= 0) && (shiftamount <= 31)) {
      if (shiftamount == 0) {
	if (!isBitSet(RM2.entire, 31)) {
	  dpi_shiftop.entire = 0;
	  dpi_shiftopcarry = getBit(RM2.entire, 31);
	} else {
	  dpi_shiftop.entire = 0xFFFFFFFF;
	  dpi_shiftopcarry = getBit(RM2.entire, 31);
	}
      } else {
	dpi_shiftop.entire = ((int32_t) RM2.entire) >> shiftamount;
	dpi_shiftopcarry = getBit(RM2.entire, shiftamount - 1);
      }
    }
    break;
  default: // Rotate right
    if ((shiftamount >= 0) && (shiftamount <= 31)) {
      if (shiftamount == 0) { //Rotate right with extend
	dpi_shiftopcarry = getBit(RM2.entire, 0);
	dpi_shiftop.entire = (((uint32_t)RM2.entire) >> 1);
	if (flags.C) setBit(dpi_shiftop.entire, 31);
      } else {
	dpi_shiftop.entire = (RotateRight(shiftamount, RM2)).entire;
	dpi_shiftopcarry = getBit(RM2.entire, shiftamount - 1);
      }
    }
  }
}

//!DPI2 - Second operand is shifted (shift amount given by third register operand)
void ac_behavior( Type_DPI2 ) {

  int rs40;
  arm_isa::reg_t RS2, RM2;

  // Special case: r* = 15
  if ((rd == 15)||(rm == 15)||(rn == 15)||(rs == 15)) {
    printf("Register 15 cannot be used in this instruction.\n");
    ac_annul(); 
  }

  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);
  rs40 = ((uint32_t)RS2.entire) & 0x0000000F;

  switch(shift){
  case 0: // Logical shift left
    if (RS2.byte[0] == 0) {
      dpi_shiftop.entire = RM2.entire;
      dpi_shiftopcarry = flags.C;
    }
    else if (((uint8_t)RS2.byte[0]) < 32) {
      dpi_shiftop.entire = RM2.entire << (uint8_t)RS2.byte[0];
      dpi_shiftopcarry = getBit(RM2.entire, 32 - ((uint8_t)RS2.byte[0]));
    }
    else if (RS2.byte[0] == 32) {
      dpi_shiftop.entire = 0;
      dpi_shiftopcarry = getBit(RM2.entire, 0);
    }
    else { // rs > 32
      dpi_shiftop.entire = 0;
      dpi_shiftopcarry = 0;
    }  
    break;
  case 1: // Logical shift right
    if (RS2.byte[0] == 0) {
      dpi_shiftop.entire = RM2.entire;
      dpi_shiftopcarry = flags.C;
    }
    else if (((uint8_t)RS2.byte[0]) < 32) {
      dpi_shiftop.entire = ((uint32_t) RM2.entire) >> ((uint8_t)RS2.byte[0]);
      dpi_shiftopcarry = getBit(RM2.entire, (uint8_t)RS2.byte[0] - 1);
    }
    else if (RS2.byte[0] == 32) {
      dpi_shiftop.entire = 0;
      dpi_shiftopcarry = getBit(RM2.entire, 31);
    }
    else { // rs > 32
      dpi_shiftop.entire = 0;
      dpi_shiftopcarry = 0;
    }  
    break;
  case 2: // Arithmetical shift right
    if (RS2.byte[0] == 0) {
      dpi_shiftop.entire = RM2.entire;
      dpi_shiftopcarry = flags.C;
    }
    else if (((uint8_t)RS2.byte[0]) < 32) {
      dpi_shiftop.entire = ((int32_t) RM2.entire) >> ((uint8_t)RS2.byte[0]);
      dpi_shiftopcarry = getBit(RM2.entire, ((uint8_t)RS2.byte[0]) - 1);
    } else { // rs >= 32
      if (!isBitSet(RM2.entire, 31)) {
	dpi_shiftop.entire = 0;
	dpi_shiftopcarry = getBit(RM2.entire, 31);
      }
      else { // rm_31 == 1
	dpi_shiftop.entire = 0xFFFFFFFF;
	dpi_shiftopcarry = getBit(RM2.entire, 31);
      }
    }
    break;
  default: // Rotate right
    if (RS2.byte[0] == 0) {
      dpi_shiftop.entire = RM2.entire;
      dpi_shiftopcarry = flags.C;
    }
    else if (rs40 == 0) {
      dpi_shiftop.entire = RM2.entire;
      dpi_shiftopcarry = getBit(RM2.entire, 31);
    }
    else { // rs40 > 0 
      dpi_shiftop.entire = (RotateRight(rs40, RM2)).entire;
      dpi_shiftopcarry = getBit(RM2.entire, rs40 - 1);
    }
  }
}

//!DPI3 - Second operand is immediate shifted by another imm
void ac_behavior( Type_DPI3 ){
  int32_t tmp;
  tmp = (uint32_t)imm8;
  dpi_shiftop.entire = (((uint32_t)tmp) >> (2 * rotate)) | (((uint32_t)tmp) << (32 - (2 * rotate)));

  if (rotate == 0) 
    dpi_shiftopcarry = flags.C;
  else 
    dpi_shiftopcarry = getBit(dpi_shiftop.entire, 31);    
}

void ac_behavior( Type_BBL ) {
  // no special actions necessary
}
void ac_behavior( Type_BBLT ) {
  // no special actions necessary
}
void ac_behavior( Type_MBXBLX ) {
  // no special actions necessary
}

//!MULT1 - 32-bit result multiplication
void ac_behavior( Type_MULT1 ) {
  // no special actions necessary
}

//!MULT2 - 64-bit result multiplication
void ac_behavior( Type_MULT2 ) {
  // no special actions necessary
}

//!LSI - Load Store Immediate Offset/Index
void ac_behavior( Type_LSI ) {

  arm_isa::reg_t RN2;
  RN2.entire = RB_read(rn);
  
  ls_address.entire = 0;
    
  if((p == 1)&&(w == 0)) { // immediate pre-indexed without writeback
    // Special case: Rn = PC
    if (rn == PC) 
      ls_address.entire = 4;
    
    if(u == 1) {
      ls_address.entire += RN2.entire + (uint32_t) imm12;
    } else {
      ls_address.entire += RN2.entire - (uint32_t) imm12;
    }
  }

  else if((p == 1)&&(w == 1)) { // immediate pre-indexed with writeback
    // Special case: Rn = PC
    if (rn == PC) {
      printf("Unpredictable LSI instruction result (Can't writeback to PC, Rn = PC)\n");
      ac_annul();
      return;
    }
    // Special case: Rn = Rd
    if (rn == rd) {
      printf("Unpredictable LSI instruction result  (Can't writeback to loaded register, Rn = Rd)\n");
      ac_annul();
      return;
    }
    
    if(u == 1) {
      ls_address.entire = RN2.entire + (uint32_t) imm12;
    } else {
      ls_address.entire = RN2.entire - (uint32_t) imm12;
    }
    RB_write(rn,ls_address.entire);
  }

  else if((p == 0)&&(w == 0)) { // immediate post-indexed (writeback)
    // Special case: Rn = PC
    if (rn == PC) {
      printf("Unpredictable LSI instruction result (Can't writeback to PC, Rn = PC)\n");
      ac_annul();
      return;
    }
    // Special case Rn = Rd
    if (rn == rd) {
      printf("Unpredictable LSI instruction result (Can't writeback to loaded register, Rn = Rd)\n");
      ac_annul();
      return;
    }
    
    ls_address.entire = RN2.entire;
    if(u == 1) {
      //checar se imm12 soma direto
      RB_write(rn, ls_address.entire + (uint32_t) imm12);
    } else {
      RB_write(rn, ls_address.entire - (uint32_t) imm12);
    }
  }
  /* FIXME: Check word alignment (Rd = PC) Address[1:0] = 0b00 */

}

//!LSR - Scaled Register Offset/Index
void ac_behavior( Type_LSR ) {

  arm_isa::reg_t RM2, RN2, index, tmp;

  RM2.entire = RB_read(rm);
  RN2.entire = RB_read(rn);
  ls_address.entire = 0;

  if ((p == 1)&&(w == 0)) { // offset
    // Special case: PC
    if(rn == PC) 
      ls_address.entire = 4;

    if(rm == PC) {
      printf("Unpredictable LSR instruction result (Illegal usage of PC, Rm = PC)\n");
      return;
    }

    switch(shift){
    case 0:
      if(shiftamount == 0) { // Register
	index.entire = RM2.entire;
      } else { // Scalled logical shift left
	index.entire = RM2.entire << shiftamount;
      }
      break;
    case 1: // logical shift right
      if(shiftamount == 0) index.entire = 0;
      else index.entire = ((uint32_t) RM2.entire) >> shiftamount;
      break;
    case 2: // arithmetic shift right
      if(shiftamount == 0) {
	if (isBitSet(RM2.entire, 31)) index.entire = 0xFFFFFFFF;
	else index.entire = 0;
      } else index.entire = ((int32_t) RM2.entire) >> shiftamount;
      break;
    default:
      if(shiftamount == 0) { // RRX
	tmp.entire = 0;
	if(flags.C) setBit(tmp.entire, 31);
	index.entire = tmp.entire | (((uint32_t) RM2.entire) >> 1);
      } else { // rotate right
	index.entire = (RotateRight(shiftamount, RM2)).entire;
      }
    }

    if(u == 1) {
      ls_address.entire += (RN2.entire + index.entire);
    } else {
      ls_address.entire += (RN2.entire - index.entire);
    }
  }

  else if((p == 1)&&(w == 1)) { // pre-indexed
    // Special case: Rn = PC
    if (rn == PC) {
      printf("Unpredictable LSR instruction result (Can't writeback to PC, Rn = PC)\n");
      ac_annul();
      return;
    }
    // Special case Rn = Rd
    if (rn == rd) {
      printf("Unpredictable LSR instruction result (Can't writeback to loaded register, Rn = Rd)\n");
      ac_annul();
      return;
    }
    // Special case Rm = PC
    if (rm == PC) {
      printf("Unpredictable LSR instruction result (Illegal usage of PC, Rm = PC)\n");
      ac_annul();
      return;
    }
    // Special case Rn = Rm
    if (rn == rm) {
      printf("Unpredictable LSR instruction result (Can't use the same register for Rn and Rm\n");
      ac_annul();
      return;
    }
    
    switch(shift){
    case 0:
      if(shiftamount == 0) { // Register
	index.entire = RM2.entire;
      } else { // Scaled logical shift left
	index.entire = RM2.entire << shiftamount;
      } 
      break;
    case 1: // logical shift right
      if(shiftamount == 0) index.entire = 0;
      else index.entire = ((uint32_t) RM2.entire) >> shiftamount;
      break;
    case 2: // arithmetic shift right
      if(shiftamount == 0) {
	if (isBitSet(RM2.entire,31)) 
	  index.entire = 0xFFFFFFFF;
	else 
	  index.entire = 0;
      } else index.entire = ((int32_t) RM2.entire) >> shiftamount;
      break;
    default:
      if(shiftamount == 0) { // RRX
	tmp.entire = 0;
	if (flags.C) setBit(tmp.entire,31);
	index.entire = tmp.entire | (((uint32_t) RM2.entire) >> 1);
      } else { // rotate right
	index.entire = (RotateRight(shiftamount, RM2)).entire;
      }
    }

    if(u == 1) {
      ls_address.entire = RN2.entire + index.entire;
    } else {
      ls_address.entire = RN2.entire - index.entire;    
    }

    RB_write(rn, ls_address.entire);
  }

  else if((p == 0)&&(w == 0)) { // post-indexed
    // Special case: Rn = PC
    if (rn == PC) {
      printf("Unpredictable LSR instruction result (Can't writeback to PC, Rn = PC)\n");
      ac_annul();
      return;
    }
    // Special case Rn = Rd
    if (rn == rd) {
      printf("Unpredictable LSR instruction result (Can't writeback to loaded register, Rn = Rd)\n");
      ac_annul();
      return;
    }
    // Special case Rm = PC
    if (rm == PC) {
      printf("Unpredictable LSR instruction result (Illegal usage of PC, Rm = PC)\n");
      ac_annul();
      return;
    }
    // Special case Rn = Rm
    if (rn == rm) {
      printf("Unpredictable LSR instruction result (Can't use the same register for Rn and Rm\n");
      ac_annul();
      return;
    }
    
    ls_address.entire = RN2.entire;

    switch(shift) {
    case 0:
      if(shiftamount == 0) { // Register
	index.entire = RM2.entire;
      } else { // Scaled logical shift left
	index.entire = RM2.entire << shiftamount;
      }
      break;
    case 1: // logical shift right
      if(shiftamount == 0) index.entire = 0;
      else index.entire = ((uint32_t) RM2.entire) >> shiftamount;
      break;
    case 2: // arithmetic shift right
      if(shiftamount == 0) {
	if (isBitSet(RM2.entire, 31)) 
	  index.entire = 0xFFFFFFFF;
	else 
	  index.entire = 0;
      } else index.entire = ((int32_t) RM2.entire) >> shiftamount;
      break;
    default:
      if(shiftamount == 0) { // RRX
	tmp.entire = 0;
	if(flags.C) setBit(tmp.entire, 31);
	index.entire = tmp.entire | (((uint32_t) RM2.entire) >> 1);	
      } else { // rotate right
	index.entire = (RotateRight(shiftamount, RM2)).entire;
      }
    }

    if(u == 1) {
      RB_write(rn, RN2.entire + index.entire);
    } else {
      RB_write(rn, RN2.entire - index.entire);
    }
  } 
}

//!LSE - Load Store HalfWord
void ac_behavior( Type_LSE ){

  int32_t off8;
  arm_isa::reg_t RM2, RN2;

  // Special cases handling
  if((p == 0)&&(w == 1)) {
    printf("Unpredictable LSE instruction result");
    ac_annul();
    return;
  }
  if((ss == 0)&&(hh == 0)) {
    printf("Decoding error: this is not a LSE instruction");
    ac_annul();
    return;
  }
  if((ss == 1)&&(l == 0)) 
    dprintf("Special DSP\n");
    // FIXME: Test LDRD and STRD second registers in case of writeback

  RN2.entire = RB_read(rn);

  // nos LSE's que usam registrador, o campo addr2 armazena Rm
  RM2.entire = RB_read(addr2);
  off8 = ((uint32_t)(addr1 << 4) | addr2);
  ls_address.entire = 0;

  if(p == 1) { // offset ou pre-indexed
    if((i == 1)&&(w == 0)) { // immediate offset
      if(rn == PC) 
	ls_address.entire = 4;
      if(u == 1) {
	ls_address.entire += (RN2.entire + off8);
      } else {
	ls_address.entire += (RN2.entire - off8);
      }
    }

    else if((i == 0)&&(w == 0)) { // register offset
      // Special case Rm = PC
      if (addr2 == PC) {
	printf("Unpredictable LSE instruction result (Illegal usage of PC, Rm = PC)\n");
	ac_annul();
	return;
      }

      if(rn == PC) 
	ls_address.entire = 4;

      if(u == 1) {
	ls_address.entire += (RN2.entire + RM2.entire);
      } else  {
	ls_address.entire += (RN2.entire - RM2.entire);
      }
    }
    
    else if ((i == 1)&&(w == 1)) { // immediate pre-indexed
      // Special case: Rn = PC
      if (rn == PC) {
	printf("Unpredictable LSE instruction result (Can't writeback to PC, Rn = PC)\n");
	ac_annul();
	return;
      }
      // Special case Rn = Rd
      if (rn == rd) {
	printf("Unpredictable LSE instruction result (Can't writeback to loaded register, Rn = Rd)\n");
	ac_annul();
	return;
      }
      
      if(u == 1) {
	ls_address.entire = (RN2.entire + off8);
      } else {
	ls_address.entire = (RN2.entire - off8);
      }

      RB_write(rn, ls_address.entire);
    }
    
    else { // i == 0 && w == 1: register pre-indexed
      // Special case: Rn = PC
      if (rn == PC) {
	printf("Unpredictable LSE instruction result (Can't writeback to PC, Rn = PC)\n");
	ac_annul();
	return;
      }
      // Special case Rn = Rd
      if (rn == rd) {
	printf("Unpredictable LSE instruction result (Can't writeback to loaded register, Rn = Rd)\n");
	ac_annul();
	return;
      }
      // Special case Rm = PC
      if (addr2 == PC) {
	printf("Unpredictable LSE instruction result (Illegal usage of PC, Rm = PC)\n");
	ac_annul();
	return;
      }
      // Special case Rn = Rm
      if (rn == addr2) {
	printf("Unpredictable LSE instruction result (Can't use the same register for Rn and Rm\n");
	ac_annul();
	return;
      }
      
      if(u == 1) {
	ls_address.entire = (RN2.entire + RM2.entire);
      } else {
	ls_address.entire = (RN2.entire - RM2.entire);
      }

      RB_write(rn, ls_address.entire);
    }

  } else { // p == 0: post-indexed
    if((i == 1)&&(w == 0)) { // immediate post-indexed
      if(rn == PC) {
	printf("Unpredictable LSE instruction result");
	ac_annul();
	return;
      }

      ls_address.entire = RN2.entire;
      if(u == 1) {
	RB_write(rn, RN2.entire + off8);
      } else {
	RB_write(rn, RN2.entire - off8);
      }
    }
    else if((i == 0)&&(w == 0)) { // register post-indexed
      // Special case: Rn = PC
      if (rn == PC) {
	printf("Unpredictable LSE instruction result (Can't writeback to PC, Rn = PC)\n");
	ac_annul();
	return;
      }
      // Special case Rn = Rd
      if (rn == rd) {
	printf("Unpredictable LSE instruction result (Can't writeback to loaded register, Rn = Rd)\n");
	ac_annul();
	return;
      }
      // Special case Rm = PC
      if (addr2 == PC) {
	printf("Unpredictable LSE instruction result (Illegal usage of PC, Rm = PC)\n");
	ac_annul();
	return;
      }
      // Special case Rn = Rm
      if (rn == addr2) {
	printf("Unpredictable LSE instruction result (Can't use the same register for Rn and Rm\n");
	ac_annul();
	return;
      }
      
      ls_address.entire = RN2.entire;
      if(u == 1) {
	RB_write(rn, RN2.entire + RM2.entire);
      } else {
	RB_write(rn, RN2.entire - RM2.entire);
      }
    }
  }
}

//!LSM - Load Store Multiple
void ac_behavior( Type_LSM ){

  arm_isa::reg_t RN2;
  int setbits;

  // Put registers list in a variable capable of addressing individual bits
  arm_isa::reg_t registerList;
  registerList.entire = (uint32_t) rlist;

  // Special case - empty list
  if (registerList.entire == 0) {
    printf("Unpredictable LSM instruction result (No register specified)\n");
    ac_annul();
    return;
  }
  
  RN2.entire = RB_read(rn);
  setbits = LSM_CountSetBits(registerList);

  // Special case Rn in Rlist
  if((w == 1)&&(isBitSet(rlist,rn))) {
    lsm_oldrn.entire = RB_read(rn);
  }

  if((p == 0)&&(u == 1)) { // increment after
    lsm_startaddress.entire = RN2.entire;
    lsm_endaddress.entire = RN2.entire + (setbits * 4) - 4;
    if(w == 1) RN2.entire += (setbits * 4);  
  }
  else if((p == 1)&&(u == 1)) { // increment before
    lsm_startaddress.entire = RN2.entire + 4; 
    lsm_endaddress.entire = RN2.entire + (setbits * 4);
    if(w == 1) RN2.entire += (setbits * 4);
  }
  else if((p == 0)&&(u == 0)) { // decrement after
    lsm_startaddress.entire = RN2.entire - (setbits * 4) + 4;
    lsm_endaddress.entire = RN2.entire;
    if(w == 1) RN2.entire -= (setbits * 4);
  }
  else { // decrement before
    lsm_startaddress.entire = RN2.entire - (setbits * 4);
    lsm_endaddress.entire = RN2.entire - 4;
    if(w == 1) RN2.entire -= (setbits * 4);
  }

  RB_write(rn,RN2.entire);
}

void ac_behavior( Type_CDP ){
  // no special actions necessary
}
void ac_behavior( Type_CRT ){
  // no special actions necessary
}
void ac_behavior( Type_CLS ){
  // no special actions necessary
}
void ac_behavior( Type_MBKPT ){
  // no special actions necessary
}
void ac_behavior( Type_MSWI ){
  // no special actions necessary
}
void ac_behavior( Type_MCLZ ){
  // no special actions necessary
}
void ac_behavior( Type_MMSR1 ){
  // no special actions necessary
}
void ac_behavior( Type_MMSR2 ){
  // no special actions necessary
}

void ac_behavior( Type_DSPSM ){

  arm_isa::reg_t RM2, RS2;
  
  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);
  
  // Special cases
  if((drd == PC)||(drn == PC)||(rm == PC)||(rs == PC)) {
    printf("Unpredictable SMLA<y><x> instruction result\n");
    return;  
  }
  
  if(xx == 0)
    OP1.entire = SignExtend(RM2.entire, 16);
  else
    OP1.entire = SignExtend((RM2.entire >> 16), 16);
  
  if(yy == 0)
    OP2.entire = SignExtend(RS2.entire, 16);
  else
    OP2.entire = SignExtend((RS2.entire >> 16), 16);
}


//! Behavior Methods

//------------------------------------------------------
void arm_isa::ADC(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  arm_isa::r64bit_t soma;

  dprintf("Instruction: ADC\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n  Carry=%d\n", RN2.entire,dpi_shiftop.entire,flags.C);
  soma.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)dpi_shiftop.entire;
  if (flags.C) soma.hilo++;
  RD2.entire = soma.reg[0];
  RB_write(rd, RD2.entire);
  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    printf("Unpredictable ADC instruction result\n");
    return;
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = ((soma.reg[1] != 0) ? true : false);
      flags.V = (((getBit(RN2.entire,31) && getBit(dpi_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(RN2.entire,31)) && (!getBit(dpi_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::ADD(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  arm_isa::r64bit_t soma;

  dprintf("Instruction: ADD\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  soma.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)dpi_shiftop.entire;
  RD2.entire = soma.reg[0];
  RB_write(rd, RD2.entire);
  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable ADD instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = ((soma.reg[1] != 0) ? true : false);
      flags.V = (((getBit(RN2.entire,31) && getBit(dpi_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(RN2.entire,31)) && (!getBit(dpi_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::AND(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  
  dprintf("Instruction: AND\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  RD2.entire = RN2.entire & dpi_shiftop.entire;
  RB_write(rd, RD2.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable AND instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire, 31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = dpi_shiftopcarry;
      // nothing happens with flags.V 
    }
  }   
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::B(int h, int offset) {

    uint32_t mem_pos, s_extend;

    // Note that PC is already incremented by 4, i.e., pointing to the next instruction

    if(h == 1) 
    { // h? it is really "l"
        dprintf("Instruction: BL\n");
        RB_write(LR, RB_read(PC));
        dprintf("Branch return address: 0x%lX\n", RB_read(LR));
    } else { 
        dprintf("Instruction: B\n");
    }

    s_extend = arm_isa::SignExtend((int32_t)(offset << 2), 26);
    mem_pos = (uint32_t)RB_read(PC) + 4 + s_extend;
    dprintf("Calculated branch destination: 0x%X\n", mem_pos);
    RB_write(PC, mem_pos);

    //fprintf(stderr, "0x%X\n", (unsigned int)mem_pos);

    ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::BX(int rm) {

  dprintf("Instruction: BX\n");

  if(isBitSet(rm,0)) {
    dprintf("Change to thumb not implemented in this model. PC=%X\n", ac_pc.read());
//    return;
  } 

  flags.T = isBitSet(rm, 0);
  ac_pc = RB_read(rm) & 0xFFFFFFFE;

  //dprintf("Pc = 0x%X",ac_pc);
}

//------------------------------------------------------
void arm_isa::BIC(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  
  dprintf("Instruction: BIC\n");
  RN2.entire = RB_read(rn);
  RD2.entire = RN2.entire & ~dpi_shiftop.entire;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  RB_write(rd,RD2.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable BIC instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = dpi_shiftopcarry;
      // nothing happens with flags.V 
    }
  }   
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::CDP(){
  dprintf("Instruction: CDP\n");
  fprintf(stderr,"Warning: CDP is not implemented in this model.\n");
}

//------------------------------------------------------
void arm_isa::CLZ(int rd, int rm) {

  arm_isa::reg_t RD2, RM2;
  int i;

  dprintf("Instruction: CLZ\n");

  // Special cases
#ifndef FORGIVE_UNPREDICTABLE
  if((rd == PC)||(rm == PC)) {
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable CLZ instruction result\n");
      return;
    }
    SPSRtoCPSR();
  }
#endif

  RM2.entire = RB_read(rm);

  if(RM2.entire == 0) RD2.entire = 32;
  else {
    i = 31;
    while((i>=0)&&(!isBitSet(RM2.entire,i))) i--;
    RD2.entire = 31 - i;
  }

  RB_write(rd, RD2.entire);
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
    
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::CMN(int rn) {

  arm_isa::reg_t RN2, alu_out;
  arm_isa::r64bit_t soma;

  dprintf("Instruction: CMN\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  soma.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)dpi_shiftop.entire;
  alu_out.entire = soma.reg[0];

  flags.N = getBit(alu_out.entire,31);
  flags.Z = ((alu_out.entire == 0) ? true : false);
  flags.C = ((soma.reg[1] != 0) ? true : false);
  flags.V = (((getBit(RN2.entire,31) && getBit(dpi_shiftop.entire,31) && (!getBit(alu_out.entire,31))) ||
	      ((!getBit(RN2.entire,31)) && (!getBit(dpi_shiftop.entire,31)) && getBit(alu_out.entire,31))) ? true : false);

  dprintf("Results: 0x%lX\n *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", alu_out.entire,flags.N,flags.Z,flags.C,flags.V);    
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::CMP(int rn) {

  arm_isa::reg_t RN2, alu_out, neg_shiftop;
  arm_isa::r64bit_t result;

  dprintf("Instruction: CMP\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  neg_shiftop.entire = - dpi_shiftop.entire;
  result.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)neg_shiftop.entire;
  alu_out.entire = result.reg[0];

  flags.N = getBit(alu_out.entire,31);
  flags.Z = ((alu_out.entire == 0) ? true : false);
  flags.C = !(((uint32_t) dpi_shiftop.entire > (uint32_t) RN2.entire) ? true : false);
  flags.V = (((getBit(RN2.entire,31) && getBit(neg_shiftop.entire,31) && (!getBit(alu_out.entire,31))) ||
	      ((!getBit(RN2.entire,31)) && (!getBit(neg_shiftop.entire,31)) && getBit(alu_out.entire,31))) ? true : false);
  
  dprintf("Results: 0x%lX\n *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n", alu_out.entire,flags.N,flags.Z,flags.C,flags.V);     
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::EOR(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  
  dprintf("Instruction: EOR\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  RD2.entire = RN2.entire ^ dpi_shiftop.entire;
  RB_write(rd, RD2.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable EOR instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire, 31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = dpi_shiftopcarry;
      // nothing happens with flags.V 
    }
  }   
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V); 
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDC(){
  dprintf("Instruction: LDC\n");
  fprintf(stderr,"Warning: LDC instruction is not implemented in this model.\n");
}

//------------------------------------------------------
void arm_isa::LDM(int rlist, bool r) {

  // todo special cases

  int i;
  int32_t value;

  if (r == 0) { // LDM(1)
    dprintf("Instruction: LDM\n");
    ls_address = lsm_startaddress;
    dprintf("Initial address: 0x%lX\n",ls_address.entire);
    for(i=0;i<15;i++){
      if(isBitSet(rlist,i)) {
        RB_write(i,DATA_PORT->read(ls_address.entire));
        ls_address.entire += 4;
        dprintf(" *  Loaded register: 0x%X; Value: 0x%X; Next address: 0x%lX\n", i,RB_read(i),ls_address.entire-4);
      }
    }
    
    if((isBitSet(rlist,PC))) { // LDM(1)
      value = DATA_PORT->read(ls_address.entire);
      RB_write(PC,value & 0xFFFFFFFE);
      ls_address.entire += 4;
      dprintf(" *  Loaded register: PC; Next address: 0x%lX\n", ls_address.entire);
    }
  } else {    
    // LDM(2) similar to LDM(1), except for the above "if"
#ifndef FORGIVE_UNPREDICTABLE
    if (!in_a_privileged_mode()) {
      fprintf (stderr, "Unpredictable behavior for LDM2/LDM3\n");
      abort();
    }
#endif
    dprintf("Instruction: LDM\n");
    ls_address = lsm_startaddress;
    dprintf("Initial address: 0x%lX\n",ls_address.entire);
    for(i=0;i<15;i++){
      if(isBitSet(rlist,i)) {
        RB.write(i,DATA_PORT->read(ls_address.entire));
        ls_address.entire += 4;
        dprintf(" *  Loaded register: 0x%X; Value: 0x%X; Next address: 0x%lX\n", i,RB_read(i),ls_address.entire);
      }
    }
    if((isBitSet(rlist,PC))) { // LDM(3)
      value = DATA_PORT->read(ls_address.entire);
      RB.write(PC,value & 0xFFFFFFFE);
      ls_address.entire += 4;
      dprintf(" *  Loaded register: PC; Next address: 0x%lX\n", ls_address.entire);
#ifndef FORGIVE_UNPREDICTABLE
      SPSRtoCPSR();
#endif
    }
  }

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDR(int rd, int rn) {

  int32_t value;
  arm_isa::reg_t tmp;
  int addr10;

  dprintf("Instruction: LDR\n");
  addr10 = (uint32_t) ls_address.entire & 0x00000003;
  ls_address.entire &= 0xFFFFFFFC;

  // Special cases
  // TODO: Verify coprocessor cases (alignment)
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
      
  switch(addr10) {
  case 0:
    value = DATA_PORT->read(ls_address.entire);
    break;
  case 1:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = (arm_isa::RotateRight(8,tmp)).entire;
    break;
  case 2:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = (arm_isa::RotateRight(16,tmp)).entire;
    break;
  default:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = (arm_isa::RotateRight(24,tmp)).entire;
  }
    
  if(rd == PC) {
    RB_write(PC,(value & 0xFFFFFFFE));
    flags.T = isBitSet(value,0);
    dprintf(" *  PC <= 0x%08X\n", value & 0xFFFFFFFE);
  }
  else 
    {
      RB_write(rd,value);
      dprintf(" *  R%d <= 0x%08X\n", rd, value);
    }

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRB(int rd, int rn) {
  uint8_t value;

  dprintf("Instruction: LDRB\n");

  // Special cases
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
  value = (uint8_t) DATA_PORT->read_byte(ls_address.entire);
  
  dprintf("Byte: 0x%X\n", value);
  RB_write(rd, ((uint32_t)value));

  dprintf(" *  R%d <= 0x%02X\n", rd, value);

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRBT(int rd, int rn) {

  uint8_t value;

  dprintf("Instruction: LDRBT\n");

  // Special cases
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
  value = (uint8_t) DATA_PORT->read_byte(ls_address.entire);
  
  dprintf("Byte: 0x%X\n", (uint32_t) value);
  RB_write(rd, (uint32_t) value);

  dprintf(" *  R%d <= 0x%02X\n", rd, value);

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRD(int rd, int rn) {
  uint32_t value1, value2;

  dprintf("Instruction: LDRD\n");
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
  value1 = DATA_PORT->read_byte(ls_address.entire);
  value2 = DATA_PORT->read_byte(ls_address.entire+4);

  // Special cases
  // Registrador destino deve ser par
  if(isBitSet(rd,0)){
    printf("Undefined LDRD instruction result (Rd must be even)\n");
    return;
  }
  // Verificar alinhamento do doubleword
  if((rd == LR)||(ls_address.entire & 0x00000007)){
    printf("Unpredictable LDRD instruction result (Address is not doubleword aligned) @ 0x%08X\n", RB_read(PC)-4);
    return;
  }

  //FIXME: Verify if writeback receives +4 from address
  RB_write(rd, value1);
  RB_write(rd+1, value2);

  dprintf(" *  R%d <= 0x%08X\n *  R%d <= 0x%08X\n (little) value = 0x%08X%08X\n (big) value = 0x%08X08X\n", rd, value1, rd+1, value2, value2, value1, value1, value2);

  ac_pc = RB_read(PC);
}
//------------------------------------------------------
void arm_isa::LDRH(int rd, int rn) {
  uint32_t value;

  dprintf("Instruction: LDRH\n");
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
  // Special cases
  // verify coprocessor alignment
  // verify halfword alignment
  if(isBitSet(ls_address.entire,0)){
    printf("Unpredictable LDRH instruction result (Address is not Halfword Aligned)\n");
    return;
  }
  value = DATA_PORT->read_half(ls_address.entire);

  RB_write(rd, value);

  dprintf(" *  R%d <= 0x%04X\n", rd, value); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRSB(int rd, int rn) {

  uint32_t data;

  dprintf("Instruction: LDRSB\n");
    
  // Special cases
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);  
  data = DATA_PORT->read_byte(ls_address.entire);
  data = arm_isa::SignExtend(data, 8);

  RB_write(rd, data);

  dprintf(" *  R%d <= 0x%08X\n", rd, data); 
 
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRSH(int rd, int rn){

  uint32_t data;

  dprintf("Instruction: LDRSH\n");
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);    
  // Special cases
  // verificar alinhamento do halfword
  if(isBitSet(ls_address.entire, 0)) {
    printf("Unpredictable LDRSH instruction result (Address is not halfword aligned)\n");
    return;
  }
  // Verify coprocessor alignment

  data = DATA_PORT->read_half(ls_address.entire);
  
  data = arm_isa::SignExtend(data,16);
  RB_write(rd, data);

  dprintf(" *  R%d <= 0x%08X\n", rd, data); 
    
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::LDRT(int rd, int rn) {

  int addr10;
  arm_isa::reg_t tmp;
  uint32_t value;

  dprintf("Instruction: LDRT\n");

  addr10 = (int)ls_address.entire & 0x00000003;
  ls_address.entire &= 0xFFFFFFFC;
  dprintf("Reading memory position 0x%08X\n", ls_address.entire);
    
  // Special cases
  // Verify coprocessor alignment
    
  switch(addr10) {
  case 0:
    value = DATA_PORT->read(ls_address.entire);
    RB_write(rd, value);
    break;
  case 1:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = arm_isa::RotateRight(8,tmp).entire;
    RB_write(rd, value);
    break;
  case 2:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = arm_isa::RotateRight(16,tmp).entire;
    RB_write(rd, value);
    break;
  default:
    tmp.entire = DATA_PORT->read(ls_address.entire);
    value = arm_isa::RotateRight(24, tmp).entire;
    RB_write(rd, value);
  }

  dprintf(" *  R%d <= 0x%08X\n", rd, value); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::MCR(){
  dprintf("Instruction: MCR\n");
  fprintf(stderr, "Warning: MCR instruction is not implemented in this model.\n");
}

//------------------------------------------------------
void arm_isa::MLA(int rd, int rn, int rm, int rs, bool s) {

  arm_isa::reg_t RD2, RN2, RM2, RS2;
  RN2.entire = RB_read(rn);
  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);

  dprintf("Instruction: MLA\n");
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n  C = 0x%lX\n", RM2.entire, RS2.entire, RN2.entire);

  // Special cases
  if((rd == PC)||(rm == PC)||(rs == PC)||(rn == PC)||(rd == rm)) {
    fprintf(stderr, "Unpredictable MLA instruction result\n");
    return;    
  }

  RD2.entire = RM2.entire * RS2.entire + RN2.entire;
  if(s == 1) {
    flags.N = getBit(RD2.entire,31);
    flags.Z = ((RD2.entire == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }
  RB_write(rd,RD2.entire);

  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::MOV(int rd, bool s) {
  
  dprintf("Instruction: MOV\n");
  RB_write(rd, dpi_shiftop.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable MOV instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  }
  if (s == 1) {
    flags.N = getBit(dpi_shiftop.entire, 31);
    flags.Z = ((dpi_shiftop.entire == 0) ? true : false);
    flags.C = dpi_shiftopcarry;
    // nothing happens with flags.V 
  }
     
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, dpi_shiftop.entire, dpi_shiftop.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::MRC(){
  dprintf("Instruction: MRC\n");
  fprintf(stderr, "Warning: MRC instruction is not implemented in this model.\n");
}

//------------------------------------------------------
void arm_isa::MRS(int rd, bool r, int zero3, int subop2, int func2, int subop1, int rm, int field) {

  unsigned res;

  dprintf("Instruction: MRS\n");

  // Special cases
  if((rd == PC)||((zero3 != 0)&&(subop2 != 0)&&(func2 != 0)&&(subop1 != 0)&&(rm != 0))||(field != 15)) {
    printf("Unpredictable MRS instruction result\n");
    dprintf("**! Unpredictable MRS instruction result\n");
    return;
  }

  if (r == 1) {
    if (!in_a_privileged_mode()) {
      printf("Unpredictable MRS instruction result\n");
      dprintf("**! Unpredictable MRS instruction result\n");
      return;
    }
    res = readSPSR();
    dprintf("Read SPSR.\n");
  } else {
    res = readCPSR();
    dprintf("Read CPSR.\n");
  }

  RB_write(rd,res);

  dprintf(" *  R%d <= 0x%08X\n", rd, res); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::MUL(int rd, int rm, int rs, bool s) {

  arm_isa::reg_t RD2, RM2, RS2;
  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);

  dprintf("Instruction: MUL\n");
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RM2.entire, RS2.entire);

  // Special cases
  if((rd == PC)||(rm == PC)||(rs == PC)||(rd == rm)) {
    fprintf(stderr, "Unpredictable MUL instruction result\n");
//    return;    
  }

  RD2.entire = RM2.entire * RS2.entire;
  if(s == 1) {
    flags.N = getBit(RD2.entire, 31);
    flags.Z = ((RD2.entire == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }
  RB_write(rd, RD2.entire);

  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::MVN(int rd, bool s) {

  dprintf("Instruction: MVN\n");
  RB_write(rd,~dpi_shiftop.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable MVN instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(~dpi_shiftop.entire,31);
      flags.Z = ((~dpi_shiftop.entire == 0) ? true : false);
      flags.C = dpi_shiftopcarry;
      // nothing happens with flags.V 
    }
  }   

  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, ~dpi_shiftop.entire, ~dpi_shiftop.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::ORR(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2;
  
  dprintf("Instruction: ORR\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  RD2.entire = RN2.entire | dpi_shiftop.entire;
  RB_write(rd,RD2.entire);

  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable ORR instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = dpi_shiftopcarry;
      // nothing happens with flags.V 
    }
  }  
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);  
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::RSB(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2, neg_RN2;
  arm_isa::r64bit_t result;

  dprintf("Instruction: RSB\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  neg_RN2.entire = - RN2.entire;
  result.hilo = (uint64_t)(uint32_t)dpi_shiftop.entire + (uint64_t)(uint32_t)neg_RN2.entire;
  RD2.entire = result.reg[0];
  RB_write(rd, RD2.entire);
  if ((s == 1) && (rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable RSB instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = !(((uint32_t) RN2.entire > (uint32_t) dpi_shiftop.entire) ? true : false);
      flags.V = (((getBit(neg_RN2.entire,31) && getBit(dpi_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(neg_RN2.entire,31)) && (!getBit(dpi_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::RSC(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2, neg_RN2;
  arm_isa::r64bit_t result;

  dprintf("Instruction: RSC\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n  Carry = %d\n", RN2.entire,dpi_shiftop.entire, flags.C);
  if (!flags.C) { RN2.entire++; }  
  neg_RN2.entire = - RN2.entire;
  result.hilo = (uint64_t)(uint32_t)dpi_shiftop.entire + (uint64_t)(uint32_t)neg_RN2.entire;
  RD2.entire = result.reg[0];

  RB_write(rd, RD2.entire);
  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable RSC instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      if ((!flags.C)&&(RN2.entire == 0))    
          flags.C = false;                  
      else
          flags.C = !(((uint32_t) RN2.entire > (uint32_t) dpi_shiftop.entire) ? true : false);
      flags.V = (((getBit(neg_RN2.entire,31) && getBit(dpi_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(neg_RN2.entire,31)) && (!getBit(dpi_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::SBC(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2, neg_shiftop;
  arm_isa::r64bit_t result;

  dprintf("Instruction: SBC\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n  Carry = %d\n", RN2.entire,dpi_shiftop.entire, flags.C);
  if (!flags.C) dpi_shiftop.entire++;     
  neg_shiftop.entire = - dpi_shiftop.entire;   
  result.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)neg_shiftop.entire;
  RD2.entire = result.reg[0];
  RB_write(rd, RD2.entire);
  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable SBC instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      if ((!flags.C)&&(dpi_shiftop.entire==0))
          flags.C = false;
      else
          flags.C = !(((uint32_t) dpi_shiftop.entire > (uint32_t) RN2.entire) ? true : false);
      flags.V = (((getBit(RN2.entire,31) && getBit(neg_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(RN2.entire,31)) && (!getBit(neg_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire);
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::SMLAL(int rdhi, int rdlo, int rm, int rs, bool s) {

  arm_isa::r64bit_t result, acc;
  arm_isa::reg_t RM2, RS2;

  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);
  acc.reg[0] = RB_read(rdlo);
  acc.reg[1] = RB_read(rdhi);

  dprintf("Instruction: SMLAL\n");
  dprintf("Operands:\n  rm=0x%X, contains 0x%lX\n  rs=0x%X, contains 0x%lX\n  Add multiply result to %lld\nDestination(Hi): Rdhi=0x%X, Rdlo=0x%X\n", rm,RM2.entire,rs,RS2.entire,acc.hilo,rdhi,rdlo);

  // Special cases
  if((rdhi == PC)||(rdlo == PC)||(rm == PC)||(rs == PC)||(rdhi == rdlo)||(rdhi == rm)||(rdlo == rm)) {
    printf("Unpredictable SMLAL instruction result\n");
    return;  
  }

  result.hilo = (int64_t)RM2.entire * (int64_t)RS2.entire + acc.hilo;
  RB_write(rdhi,result.reg[1]);
  RB_write(rdlo,result.reg[0]);
  if(s == 1){
    flags.N = getBit(result.reg[1],31);
    flags.Z = ((result.hilo == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }
  dprintf(" *  R%d(high) R%d(low) <= 0x%08X%08X (%d)\n", rdhi, rdlo, result.reg[1], result.reg[0], result.reg[0]); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::SMULL(int rdhi, int rdlo, int rm, int rs, bool s) {

  arm_isa::r64bit_t result;
  arm_isa::reg_t RM2, RS2;

  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);

  dprintf("Instruction: SMULL\n");
  dprintf("Operands:\n  rm=0x%X, contains 0x%lX\n  rs=0x%X, contains 0x%lX\n  Destination(Hi): Rdhi=0x%X, Rdlo=0x%X\n", rm,RM2.entire,rs,RS2.entire,rdhi,rdlo);

  // Special cases
  if((rdhi == PC)||(rdlo == PC)||(rm == PC)||(rs == PC)||(rdhi == rdlo)||(rdhi == rm)||(rdlo == rm)) {
    printf("Unpredictable SMULL instruction result\n");
    return;  
  }

  result.hilo = (int64_t)RM2.entire * (int64_t)RS2.entire;
  RB_write(rdhi,result.reg[1]);
  RB_write(rdlo,result.reg[0]);
  if(s == 1){
    flags.N = getBit(result.reg[1],31);
    flags.Z = ((result.hilo == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }
  dprintf(" *  R%d(high) R%d(low) <= 0x%08X%08X (%d)\n", rdhi, rdlo, result.reg[1], result.reg[0], result.reg[0]);
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STC(){
  dprintf("Instruction: STC\n");
  fprintf(stderr,"Warning: STC instruction is not implemented in this model.\n");
}

//------------------------------------------------------
void arm_isa::STM(int rn, int rlist, unsigned r) {

    // todo special cases

    int i;

    if (r == 0) { // STM(1) 
        dprintf("Instruction: STM\n");
        ls_address = lsm_startaddress;
        for(i=0;i<16;i++){
            if(isBitSet(rlist,i)) {
                // rn is in rlist. e.g. push {sp,...}
                if (i == rn)
                    DATA_PORT->write(ls_address.entire,lsm_oldrn.entire);
                else 
                    DATA_PORT->write(ls_address.entire,RB_read(i));

                ls_address.entire += 4;
                dprintf(" *  Stored register: 0x%X; value: 0x%X; address: 0x%lX\n",i,RB_read(i),ls_address.entire-4);
            }
        }
    } else { // STM(2)
#ifndef FORGIVE_UNPREDICTABLE
        if (!in_a_privileged_mode()) {
            fprintf(stderr, "STM(2) unpredictable in user mode");
            abort();
        }
#endif
        dprintf("Instruction: STM(2)\n");
        ls_address = lsm_startaddress;
        for(i=0;i<16;i++){
            if(isBitSet(rlist,i)) {
                DATA_PORT->write(ls_address.entire,RB .read(i));
                ls_address.entire += 4;
                dprintf(" *  Stored register: 0x%X; value: 0x%X; address: 0x%lX\n",i,RB_read(i),ls_address.entire-4);
            }
        }
    }

    ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STR(int rd, int rn) {

  dprintf("Instruction: STR\n");

  // Special cases
  // verify coprocessor alignment
  
  DATA_PORT->write(ls_address.entire, RB_read(rd));

  dprintf(" *  MEM[0x%08X] <= 0x%08X\n", ls_address.entire, RB_read(rd)); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STRB(int rd, int rn) {

  arm_isa::reg_t RD2;

  dprintf("Instruction: STRB\n");

  // Special cases

  RD2.entire = RB_read(rd);
  DATA_PORT->write_byte(ls_address.entire, RD2.byte[0]);

  dprintf(" *  MEM[0x%08X] <= 0x%02X\n", ls_address.entire, RD2.byte[0]); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STRBT(int rd, int rn) {

  arm_isa::reg_t RD2;

  dprintf("Instruction: STRBT\n");

  // Special cases
  
  RD2.entire = RB_read(rd);
  DATA_PORT->write_byte(ls_address.entire, RD2.byte[0]);

  dprintf(" *  MEM[0x%08X] <= 0x%02X\n", ls_address.entire, RD2.byte[0]); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STRD(int rd, int rn) {

  dprintf("Instruction: STRD\n");

  // Special cases
  // Destination register must be even
  if(isBitSet(rd,0)){
    printf("Undefined STRD instruction result (Rd must be even)\n");
    return;
  }
  // Check doubleword alignment
  if((rd == LR)||(ls_address.entire & 0x00000007)){
    printf("Unpredictable STRD instruction result (Address is not doubleword aligned)\n");
    return;
  }

  //FIXME: Check if writeback receives +4 from second address
  DATA_PORT->write(ls_address.entire,RB_read(rd));
  DATA_PORT->write(ls_address.entire+4,RB_read(rd+1));

  dprintf(" *  MEM[0x%08X], *DATA_PORT[0x%08X] <= 0x%08X %08X\n", ls_address.entire, ls_address.entire+4, RB_read(rd+1), RB_read(rd)); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STRH(int rd, int rn) {

  int16_t data;

  dprintf("Instruction: STRH\n");
    
  // Special cases
  // verify coprocessor alignment
  // verify halfword alignment
  if(isBitSet(ls_address.entire,0)){
    printf("Unpredictable STRH instruction result (Address is not halfword aligned)\n");
    return;
  }

  data = (int16_t) (RB_read(rd) & 0x0000FFFF);
  DATA_PORT->write_half(ls_address.entire, data);

  dprintf(" *  MEM[0x%08X] <= 0x%04X\n", ls_address.entire, data); 
    
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::STRT(int rd, int rn) {

  dprintf("Instruction: STRT\n");

  // Special cases
  // verificar caso do coprocessador (alinhamento)
  
  DATA_PORT->write(ls_address.entire, RB_read(rd));

  dprintf(" *  MEM[0x%08X] <= 0x%08X\n", ls_address.entire, RB_read(rd)); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::SUB(int rd, int rn, bool s) {

  arm_isa::reg_t RD2, RN2, neg_shiftop;
  arm_isa::r64bit_t result;

  dprintf("Instruction: SUB\n");
  RN2.entire = RB_read(rn);
  if(rn == PC) RN2.entire += 4;
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  neg_shiftop.entire = - dpi_shiftop.entire;
  result.hilo = (uint64_t)(uint32_t)RN2.entire + (uint64_t)(uint32_t)neg_shiftop.entire;
  RD2.entire = result.reg[0];
  RB_write(rd, RD2.entire);
  if ((s == 1)&&(rd == PC)) {
#ifndef FORGIVE_UNPREDICTABLE
    if (arm_proc_mode.mode == arm_isa::processor_mode::USER_MODE ||
        arm_proc_mode.mode == arm_isa::processor_mode::SYSTEM_MODE) {
      printf("Unpredictable SUB instruction result\n");
      return;
    }
    SPSRtoCPSR();
#endif
  } else {
    if (s == 1) {
      flags.N = getBit(RD2.entire,31);
      flags.Z = ((RD2.entire == 0) ? true : false);
      flags.C = !(((uint32_t) dpi_shiftop.entire > (uint32_t) RN2.entire) ? true : false);
      flags.V = (((getBit(RN2.entire,31) && getBit(neg_shiftop.entire,31) && (!getBit(RD2.entire,31))) ||
		  ((!getBit(RN2.entire,31)) && (!getBit(neg_shiftop.entire,31)) && getBit(RD2.entire,31))) ? true : false);
    }
  }
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
 
}

//------------------------------------------------------
void arm_isa::SWP(int rd, int rn, int rm) {

  arm_isa::reg_t RN2, RM2, rtmp;
  int32_t tmp;
  int rn10;

  dprintf("Instruction: SWP\n");

  // Special cases
  // verify coprocessor alignment
  if((rd == PC)||(rm == PC)||(rn == PC)||(rm == rn)||(rn == rd)){
    printf("Unpredictable SWP instruction result\n");
    return;
  }

  RN2.entire = RB_read(rn);
  RM2.entire = RB_read(rm);
  rn10 = RN2.entire & 0x00000003;

  switch(rn10) {
  case 0:
    tmp = DATA_PORT->read(RN2.entire);
    break;
  case 1:
    rtmp.entire = DATA_PORT->read(RN2.entire);
    tmp = (arm_isa::RotateRight(8,rtmp)).entire;
    break;
  case 2:
    rtmp.entire = DATA_PORT->read(RN2.entire);
    tmp = (arm_isa::RotateRight(16,rtmp)).entire;
    break;
  default:
    rtmp.entire = DATA_PORT->read(RN2.entire);
    tmp = (arm_isa::RotateRight(24,rtmp)).entire;
  }
    
  DATA_PORT->write(RN2.entire,RM2.entire);
  RB_write(rd,tmp);

  dprintf(" *  MEM[0x%08X] <= 0x%08X (%d)\n", RN2.entire, RM2.entire, RM2.entire); 
  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, tmp, tmp); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::SWPB(int rd, int rn, int rm) {

  uint32_t tmp;
  arm_isa::reg_t RM2, RN2;

  dprintf("Instruction: SWPB\n");

  // Special cases
  if((rd == PC)||(rm == PC)||(rn == PC)||(rm == rn)||(rn == rd)){
    printf("Unpredictable SWPB instruction result\n");
    return;
  }

  RM2.entire = RB_read(rm);
  RN2.entire = RB_read(rn);

  tmp = (uint32_t) DATA_PORT->read_byte(RN2.entire);
  DATA_PORT->write_byte(RN2.entire,RM2.byte[0]);
  RB_write(rd,tmp);

  dprintf(" *  MEM[0x%08X] <= 0x%02X (%d)\n", RN2.entire, RM2.byte[0], RM2.byte[0]); 
  dprintf(" *  R%d <= 0x%02X (%d)\n", rd, tmp, tmp); 

  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::TEQ(int rn) {

  arm_isa::reg_t RN2, alu_out;

  dprintf("Instruction: TEQ\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  alu_out.entire = RN2.entire ^ dpi_shiftop.entire;

  flags.N = getBit(alu_out.entire,31);
  flags.Z = ((alu_out.entire == 0) ? true : false);
  flags.C = dpi_shiftopcarry;
  // nothing happens with flags.V
    
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);  
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::TST(int rn) {

  arm_isa::reg_t RN2, alu_out;

  dprintf("Instruction: TST\n");
  RN2.entire = RB_read(rn);
  dprintf("Operands:\n  A = 0x%lX\n  B = 0x%lX\n", RN2.entire,dpi_shiftop.entire);
  alu_out.entire = RN2.entire & dpi_shiftop.entire;

  flags.N = getBit(alu_out.entire, 31);
  flags.Z = ((alu_out.entire == 0) ? true : false);
  flags.C = dpi_shiftopcarry;
  // nothing happens with flags.V
    
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V); 
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::UMLAL(int rdhi, int rdlo, int rm, int rs, bool s) {

  arm_isa::r64bit_t result, acc;
  arm_isa::reg_t RM2, RS2;

  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);
  acc.reg[0] = RB_read(rdlo);
  acc.reg[1] = RB_read(rdhi);

  dprintf("Instruction: UMLAL\n");
  dprintf("Operands:\n  rm=0x%X, contains 0x%lX\n  rs=0x%X, contains 0x%lX\n  Add multiply result to %lld\nDestination(Hi): Rdhi=0x%X, Rdlo=0x%X\n", rm,RM2.entire,rs,RS2.entire,acc.hilo,rdhi,rdlo);

  // Special cases
  if((rdhi == PC)||(rdlo == PC)||(rm == PC)||(rs == PC)||(rdhi == rdlo)||(rdhi == rm)||(rdlo == rm)) {
    printf("Unpredictable UMLAL instruction result\n");
    return;  
  }

  result.hilo = (uint64_t)(uint32_t)RM2.entire * (uint64_t)(uint32_t)RS2.entire 
    + (uint64_t)acc.hilo;
  RB_write(rdhi,result.reg[1]);
  RB_write(rdlo,result.reg[0]);
  if(s == 1){
    flags.N = getBit(result.reg[1],31);
    flags.Z = ((result.hilo == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }

  dprintf(" *  R%d(high) R%d(low) <= 0x%08X%08X (%d)\n", rdhi, rdlo, result.reg[1], result.reg[0], result.reg[0]); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::UMULL(int rdhi, int rdlo, int rm, int rs, bool s) {

  
  arm_isa::r64bit_t result;
  arm_isa::reg_t RM2, RS2;
  
  RM2.entire = RB_read(rm);
  RS2.entire = RB_read(rs);
  
  dprintf("Instruction: UMULL\n");
  dprintf("Operands:\n  rm=0x%X, contains 0x%lX\n  rs=0x%X, contains 0x%lX\n  Destination(Hi): Rdhi=0x%X, Rdlo=0x%X\n", rm,RM2.entire,rs,RS2.entire,rdhi,rdlo);

  // Special cases
  if((rdhi == PC)||(rdlo == PC)||(rm == PC)||(rs == PC)||(rdhi == rdlo)||(rdhi == rm)||(rdlo == rm)) {
    printf("Unpredictable UMULL instruction result\n");
    return;  
  }
  
  result.hilo = (uint64_t)(uint32_t)RM2.entire * (uint64_t)(uint32_t)RS2.entire;
  RB_write(rdhi,result.reg[1]);
  RB_write(rdlo,result.reg[0]);
  if(s == 1){
    flags.N = getBit(result.reg[1],31);
    flags.Z = ((result.hilo == 0) ? true : false);
    // nothing happens with flags.C and flags.V
  }
  dprintf(" *  R%d(high) R%d(low) <= 0x%08X%08X (%d)\n", rdhi, rdlo, result.reg[1], result.reg[0], result.reg[0]); 
  dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n",flags.N,flags.Z,flags.C,flags.V);
  ac_pc = RB_read(PC);
}

//------------------------------------------------------
void arm_isa::DSMLA(int rd, int rn) {

  arm_isa::reg_t RD2, RN2;

  RN2.entire = RB_read(rn);

  dprintf("Instruction: SMLA<y><x>\n");
  dprintf("Operands:\n  rn=0x%X, contains 0x%lX\n  first operand contains 0x%lX\n  second operand contains 0x%lX\n  rd=0x%X, contains 0x%lX\n", rn, RN2.entire, OP1.entire, OP2.entire, rd, RD2.entire);
  
  RD2.entire = (OP1.entire * OP2.entire) + RN2.entire;

  RB_write(rd, RD2.entire);

  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 

  // SET Q FLAG
}

//------------------------------------------------------
void arm_isa::DSMUL(int rd) {

  arm_isa::reg_t RD2;

  dprintf("Instruction: SMUL<y><x>\n");
  dprintf("Operands:\n  first operand contains 0x%lX\n  second operand contains 0x%lX\n  rd=0x%X, contains 0x%lX\n", OP1.entire, OP2.entire, rd, RD2.entire);
  
  RD2.entire = OP1.entire * OP2.entire;

  RB_write(rd, RD2.entire);

  dprintf(" *  R%d <= 0x%08X (%d)\n", rd, RD2.entire, RD2.entire); 

  // SET Q FLAG
}

//------------------------------------------------------


//!Instruction and1 behavior method.
void ac_behavior( and1 ){ AND(rd, rn, s);}

//!Instruction eor1 behavior method.
void ac_behavior( eor1 ){ EOR(rd, rn, s);}

//!Instruction sub1 behavior method.
void ac_behavior( sub1 ){ SUB(rd, rn, s);}

//!Instruction rsb1 behavior method.
void ac_behavior( rsb1 ){ RSB(rd, rn, s);}

//!Instruction add1 behavior method.
void ac_behavior( add1 ){ ADD(rd, rn, s);}

//!Instruction adc1 behavior method.
void ac_behavior( adc1 ){ ADC(rd, rn, s);}

//!Instruction sbc1 behavior method.
void ac_behavior( sbc1 ){ SBC(rd, rn, s);}

//!Instruction rsc1 behavior method.
void ac_behavior( rsc1 ){ RSC(rd, rn, s);}

//!Instruction tst1 behavior method.
void ac_behavior( tst1 ){ TST(rn);}

//!Instruction teq1 behavior method.
void ac_behavior( teq1 ){ TEQ(rn);}

//!Instruction cmp1 behavior method.
void ac_behavior( cmp1 ){ CMP(rn);}

//!Instruction cmn1 behavior method.
void ac_behavior( cmn1 ){ CMN(rn);}

//!Instruction orr1 behavior method.
void ac_behavior( orr1 ){ ORR(rd, rn, s);}

//!Instruction mov1 behavior method.
void ac_behavior( mov1 ){ MOV(rd, s);}

//!Instruction bic1 behavior method.
void ac_behavior( bic1 ){ BIC(rd, rn, s);}

//!Instruction mvn1 behavior method.
void ac_behavior( mvn1 ){ MVN(rd, s);}

//!Instruction and2 behavior method.
void ac_behavior( and2 ){ AND(rd, rn, s);}

//!Instruction eor2 behavior method.
void ac_behavior( eor2 ){ EOR(rd, rn, s);}

//!Instruction sub2 behavior method.
void ac_behavior( sub2 ){ SUB(rd, rn, s);}

//!Instruction rsb2 behavior method.
void ac_behavior( rsb2 ){ RSB(rd, rn, s);}

//!Instruction add2 behavior method.
void ac_behavior( add2 ){ ADD(rd, rn, s);}

//!Instruction adc2 behavior method.
void ac_behavior( adc2 ){ ADC(rd, rn, s);}

//!Instruction sbc2 behavior method.
void ac_behavior( sbc2 ){ SBC(rd, rn, s);}

//!Instruction rsc2 behavior method.
void ac_behavior( rsc2 ){ RSC(rd, rn, s);}

//!Instruction tst2 behavior method.
void ac_behavior( tst2 ){ TST(rn);}

//!Instruction teq2 behavior method.
void ac_behavior( teq2 ){ TEQ(rn);}

//!Instruction cmp2 behavior method.
void ac_behavior( cmp2 ){ CMP(rn);}

//!Instruction cmn2 behavior method.
void ac_behavior( cmn2 ){ CMN(rn);}

//!Instruction orr2 behavior method.
void ac_behavior( orr2 ){ ORR(rd, rn, s);}

//!Instruction mov2 behavior method.
void ac_behavior( mov2 ){ MOV(rd, s);}

//!Instruction bic2 behavior method.
void ac_behavior( bic2 ){ BIC(rd, rn, s);}

//!Instruction mvn2 behavior method.
void ac_behavior( mvn2 ){ MVN(rd, s);}

//!Instruction and3 behavior method.
void ac_behavior( and3 ){ AND(rd, rn, s);}

//!Instruction eor3 behavior method.
void ac_behavior( eor3 ){ EOR(rd, rn, s);}

//!Instruction sub3 behavior method.
void ac_behavior( sub3 ){ SUB(rd, rn, s);}

//!Instruction rsb3 behavior method.
void ac_behavior( rsb3 ){ RSB(rd, rn, s);}

//!Instruction add3 behavior method.
void ac_behavior( add3 ){ ADD(rd, rn, s);}

//!Instruction adc3 behavior method.
void ac_behavior( adc3 ){ ADC(rd, rn, s);}

//!Instruction sbc3 behavior method.
void ac_behavior( sbc3 ){ SBC(rd, rn, s);}

//!Instruction rsc3 behavior method.
void ac_behavior( rsc3 ){ RSC(rd, rn, s);}

//!Instruction tst3 behavior method.
void ac_behavior( tst3 ){ TST(rn);}

//!Instruction teq3 behavior method.
void ac_behavior( teq3 ){ TEQ(rn);}

//!Instruction cmp3 behavior method.
void ac_behavior( cmp3 ){ CMP(rn);}

//!Instruction cmn3 behavior method.
void ac_behavior( cmn3 ){ CMN(rn);}

//!Instruction orr3 behavior method.
void ac_behavior( orr3 ){ ORR(rd, rn, s);}

//!Instruction mov3 behavior method.
void ac_behavior( mov3 ){ MOV(rd, s);}

//!Instruction bic3 behavior method.
void ac_behavior( bic3 ){ BIC(rd, rn, s);}

//!Instruction mvn3 behavior method.
void ac_behavior( mvn3 ){ MVN(rd, s);}

//!Instruction b behavior method.
void ac_behavior( b ){ B(h, offset);}

//!Instruction blx1 behavior method.
void ac_behavior( blx1 ){
  fprintf(stderr,"Warning: BLX instruction is not implemented in this model. PC=%X\n", ac_pc.read());
}

//!Instruction bx behavior method.
void ac_behavior( bx ){ BX(rm); }

//!Instruction blx2 behavior method.
void ac_behavior( blx2 ){
  arm_isa::reg_t dest;
  dest.entire = RB_read(rm);
  dprintf("Instruction: BLX2\n");
  dprintf("Branch to contents of reg: 0x%X\n", rm);
  dprintf("Contents of register: 0x%lX\n", dest.entire);
  // Note that PC is already incremented by 4, i.e., pointing to the next instruction
  if(isBitSet(dest.entire,0)) {
    fprintf(stderr,"Change to thumb not implemented in this model. PC=%X\n", ac_pc.read());
    exit(EXIT_FAILURE);
  } 

  RB_write(LR, RB_read(PC));
  dprintf("Branch return address: 0x%lX\n", RB_read(LR));

  flags.T = isBitSet(rm, 0);
  RB_write(PC, dest.entire & 0xFFFFFFFE);
  ac_pc = RB_read(PC);

  dprintf("Calculated branch destination: 0x%lX\n", RB_read(PC));  
}

//!Instruction swp behavior method.
void ac_behavior( swp ){ SWP(rd, rn, rm); }

//!Instruction swpb behavior method.
void ac_behavior( swpb ){ SWPB(rd, rn, rm); }

//!Instruction mla behavior method.
void ac_behavior( mla ){ MLA(rn, rd, rm, rs, s);}
// OBS: inversao dos parametros proposital ("fields with the same name...")

//!Instruction mul behavior method.
void ac_behavior( mul ){ MUL(rn, rm, rs, s);}
// OBS: inversao dos parametros proposital ("fields with the same name...")

//!Instruction smlal behavior method.
void ac_behavior( smlal ){ SMLAL(rdhi, rdlo, rm, rs, s);}

//!Instruction smull behavior method.
void ac_behavior( smull ){ SMULL(rdhi, rdlo, rm, rs, s);}

//!Instruction umlal behavior method.
void ac_behavior( umlal ){ UMLAL(rdhi, rdlo, rm, rs, s);}

//!Instruction umull behavior method.
void ac_behavior( umull ){ UMULL(rdhi, rdlo, rm, rs, s);}

//!Instruction ldr1 behavior method.
void ac_behavior( ldr1 ){ LDR(rd, rn);  }

//!Instruction ldrt1 behavior method.
void ac_behavior( ldrt1 ){ LDRT(rd, rn); }

//!Instruction ldrb1 behavior method.
void ac_behavior( ldrb1 ){ LDRB(rd, rn); }

//!Instruction ldrbt1 behavior method.
void ac_behavior( ldrbt1 ){ LDRBT(rd, rn); }

//!Instruction str1 behavior method.
void ac_behavior( str1 ){ STR(rd, rn); }

//!Instruction strt1 behavior method.
void ac_behavior( strt1 ){ STRT(rd, rn); }

//!Instruction strb1 behavior method.
void ac_behavior( strb1 ){ STRB(rd, rn); }

//!Instruction strbt1 behavior method.
void ac_behavior( strbt1 ){ STRBT(rd, rn); }

//!Instruction ldr2 behavior method.
void ac_behavior( ldr2 ){ LDR(rd, rn); }

//!Instruction ldrt2 behavior method.
void ac_behavior( ldrt2 ){ LDRT(rd, rn); }

//!Instruction ldrb2 behavior method.
void ac_behavior( ldrb2 ){ LDRB(rd, rn); }

//!Instruction ldrbt2 behavior method.
void ac_behavior( ldrbt2 ){ LDRBT(rd, rn); }

//!Instruction str2 behavior method.
void ac_behavior( str2 ){ STR(rd, rn); }

//!Instruction strt2 behavior method.
void ac_behavior( strt2 ){ STRT(rd, rn); }

//!Instruction strb2 behavior method.
void ac_behavior( strb2 ){ STRB(rd, rn); }

//!Instruction strbt2 behavior method.
void ac_behavior( strbt2 ){ STRBT(rd, rn); }

//!Instruction ldrh behavior method.
void ac_behavior( ldrh ){ LDRH(rd, rn); }

//!Instruction ldrsb behavior method.
void ac_behavior( ldrsb ){ LDRSB(rd, rn); }

//!Instruction ldrsh behavior method.
void ac_behavior( ldrsh ){ LDRSH(rd, rn); }

//!Instruction strh behavior method.
void ac_behavior( strh ){ STRH(rd, rn); }

//!Instruction ldm behavior method.
void ac_behavior( ldm ){ LDM(rlist,r); }

//!Instruction stm behavior method.
void ac_behavior( stm ){ STM(rn, rlist, r); }

//!Instruction cdp behavior method.
void ac_behavior( cdp ){ CDP();}

//!Instruction mcr behavior method.
void ac_behavior( mcr ){ MCR();}

//!Instruction mrc behavior method.
void ac_behavior( mrc ){ MRC();}

//!Instruction ldc behavior method.
void ac_behavior( ldc ){ LDC();}

//!Instruction stc behavior method.
void ac_behavior( stc ){ STC();}

//!Instruction bkpt behavior method.
void ac_behavior( bkpt ){
  fprintf(stderr,"Warning: BKPT instruction is not implemented in this model. PC=%X\n", ac_pc.read());
}

//!Instruction swi behavior method.
void ac_behavior( swi ){
#ifdef SYSTEM_MODEL
  service_interrupt(EXCEPTION_SWI);
#else
  dprintf("Instruction: SWI\n");
  if (swinumber == 0) {
    // New ABI (EABI), expected syscall number is in r7
    unsigned sysnum = RB_read(7) + 0x900000;
    dprintf("EABI Syscall number: 0x%X\t(%d)\n", RB_read(7), RB_read(7));
    if (syscall.process_syscall(sysnum) == -1) {
      fprintf(stderr, "Warning: A syscall not implemented in this model was called.\n\tCaller address: 0x%X\n\tSyscall number: 0x%X\t%d\n", (unsigned int)ac_pc, sysnum, sysnum);
    }
    // Old ABI (syscall encoded in instruction)
  } else {
    dprintf("Syscall number: 0x%X\t%d\n", swinumber, swinumber);
    if (syscall.process_syscall(swinumber) == -1) {    
      fprintf(stderr, "Warning: A syscall not implemented in this model was called.\n\tCaller address: 0x%X\n\tSWI number: 0x%X\t(%d)\n", (unsigned int)ac_pc, swinumber, swinumber);
    }
  }
#endif
}

//!Instruction clz behavior method.
void ac_behavior( clz ){ CLZ(rd, rm);}

//!Instruction mrs behavior method.
void ac_behavior( mrs ){ MRS(rd,r,zero3,subop2,func2,subop1,rm,fieldmask);}

//!Instruction msr1 behavior method.
void ac_behavior( msr1 ){
  unsigned in = RB_read(rm);
  unsigned res;

  dprintf("Instruction: MSR\n");
  // Write to CPSR
  if (r == 0)  {
    res = readCPSR();
    if (in_a_privileged_mode()) {
      if (fieldmask & 1) {
        res &= ~0xFF;
        res |= (in & 0xFF);
      }
      if (fieldmask & (1 << 1)) {
        res &= ~0xFF00;
        res |= (in & 0xFF00);
      }
      if (fieldmask & (1 << 2)) {
        res &= ~0xFF0000;
        res |= (in & 0xFF0000);
      }
    }
    if (fieldmask & (1 << 3)) {
      res &= ~0xFF000000;
      res |= (in & 0xFF000000);
    }
    writeCPSR(res);
    dprintf(" *  CPSR <= 0x%08X\n", res); 
    dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n     FIQ disable"
            "=0x%X, IRQ disable=0x%X, Thumb=0x%X\n",flags.N,flags.Z,
            flags.C,flags.V, arm_proc_mode.fiq, arm_proc_mode.irq,
            arm_proc_mode.thumb);
    dprintf(" *  Processor mode <= %s MODE\n", cur_mode_str());
  } else { // r == 1, write to SPSR
    res = readSPSR();
    if (fieldmask & 1) {
      res &= ~0xFF;
      res |= (in & 0xFF);
    }
    if (fieldmask & (1 << 1)) {
      res &= ~0xFF00;
      res |= (in & 0xFF00);
    }
    if (fieldmask & (1 << 2)) {
      res &= ~0xFF0000;
      res |= (in & 0xFF0000);
    }  
    if (fieldmask & (1 << 3)) {
      res &= ~0xFF000000;
      res |= (in & 0xFF000000);
    }
    writeSPSR(res);
    dprintf(" *  SPSR <= 0x%08X\n", res); 
  }
}

//!Instruction msr2 behavior method.
void ac_behavior( msr2 ){
  arm_isa::reg_t temp;
  temp.entire = imm8;
  unsigned in = RotateRight(rotate*2, temp).entire;
  unsigned res;
  dprintf("Instruction: MSR\n");
  // Write to CPSR
  if (r == 0)  {
    res = readCPSR();
    if (in_a_privileged_mode()) {
      if (fieldmask & 1) {
        res &= ~0xFF;
        res |= (in & 0xFF);
      }
      if (fieldmask & (1 << 1)) {
        res &= ~0xFF00;
        res |= (in & 0xFF00);
      }
      if (fieldmask & (1 << 2)) {
        res &= ~0xFF0000;
        res |= (in & 0xFF0000);
      }
    }
    if (fieldmask & (1 << 3)) {
      res &= ~0xFF000000;
      res |= (in & 0xFF000000);
    }
    writeCPSR(res);
    dprintf(" *  CPSR <= 0x%08X\n", res); 
    dprintf(" *  Flags <= N=0x%X, Z=0x%X, C=0x%X, V=0x%X\n     FIQ disable"
            "=0x%X, IRQ disable=0x%X, Thumb=0x%X\n",flags.N,flags.Z,
            flags.C,flags.V, arm_proc_mode.fiq, arm_proc_mode.irq,
            arm_proc_mode.thumb);
    dprintf(" *  Processor mode <= %s MODE\n", cur_mode_str());
  } else { // r == 1, write to SPSR
    res = readSPSR();
    if (fieldmask & 1) {
      res &= ~0xFF;
      res |= (in & 0xFF);
    }
    if (fieldmask & (1 << 1)) {
      res &= ~0xFF00;
      res |= (in & 0xFF00);
    }
    if (fieldmask & (1 << 2)) {
      res &= ~0xFF0000;
      res |= (in & 0xFF0000);
    }  
    if (fieldmask & (1 << 3)) {
      res &= ~0xFF000000;
      res |= (in & 0xFF000000);
    }
    writeSPSR(res);
    dprintf(" *  SPSR <= 0x%08X\n", res); 
  }
}

//!Instruction ldrd2 behavior method.
void ac_behavior( ldrd ){ LDRD(rd, rn); }

//!Instruction ldrd2 behavior method.
void ac_behavior( strd ){ STRD(rd, rn); }

//!Instruction dsmla behavior method.
void ac_behavior( dsmla ){ DSMLA(drd, drn); }

//!Instruction dsmlal behavior method.
void ac_behavior( dsmlal ){
  fprintf(stderr,"Warning: SMLAL<y><x> instruction is not implemented in this model. PC=%X\n", ac_pc.read());
}

//!Instruction dsmul behavior method.
void ac_behavior( dsmul ){ DSMUL(drd); }

//!Instruction dsmlaw behavior method.
void ac_behavior( dsmlaw ){
  fprintf(stderr,"Warning: SMLAW<y><x> instruction is not implemented in this model. PC=%X\n", ac_pc.read());
}

//!Instruction dsmulw behavior method.
void ac_behavior( dsmulw ){
  fprintf(stderr,"Warning: SMULW<y><x> instruction is not implemented in this model. PC=%X\n", ac_pc.read());
}

void ac_behavior( end ) { }
