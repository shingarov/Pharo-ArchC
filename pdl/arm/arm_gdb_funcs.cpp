/**
 * @file      arm_gdb_funcs.cpp
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

#include "arm.H"

using namespace arm_parms;

int arm::nRegs(void) {
   return 16;
}

ac_word arm::reg_read( int reg ) {  
  /* general purpose registers */
  if ( ( reg >= 0 ) && ( reg < 15 ) )
    return RB.read( reg );
  else if ( reg == 15 )
    return ac_pc;
  return 0;
}

void arm::reg_write( int reg, ac_word value ) {
  /* general purpose registers */
  printf("Register is: %d, value is %x\n",reg,value);
  if ( ( reg >= 0 ) && ( reg < 15 ) )
    RB.write( reg, value );
  else if ( reg == 15 )
    ac_pc = value;
}

unsigned char arm::mem_read( unsigned int address ) {
  return DATA_PORT->read_byte(address);
}

void arm::mem_write( unsigned int address, unsigned char byte ) {
  DATA_PORT->write_byte( address, byte );
}

