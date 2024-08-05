/**
 * @file      mips_gdb_funcs.cpp
 * @author    Sandro Rigo
 *            Marcus Bartholomeu
 *            Alexandro Baldassin (acasm information)
 *
 *            The ArchC Team
 *            http://www.archc.org/
 *
 *            Computer Systems Laboratory (LSC)
 *            IC-UNICAMP
 *            http://www.lsc.ic.unicamp.br/
 *
 * @version   1.0
 * @date      Mon, 19 Jun 2006 15:50:52 -0300
 * 
 * @brief     The ArchC MIPS-I functional model.
 * 
 * @attention Copyright (C) 2002-2006 --- The ArchC Team
 *
 */

#include "mips.H"

// 'using namespace' statement to allow access to all
// mips-specific datatypes
using namespace mips_parms;

int mips::nRegs(void) {
   return 73;
}


ac_word mips::reg_read( int reg ) {
  /* general purpose registers */
  if ( ( reg >= 0 ) && ( reg < 32 ) )
    return RB.read( reg );
  else {
    if (reg == 33)
      return lo;
    else if (reg == 34)
      return hi;
    else
      /* pc */
      if ( reg == 37 )
        return ac_pc;
  }

  return 0;
}


void mips::reg_write( int reg, ac_word value ) {
  /* general purpose registers */
  if ( ( reg >= 0 ) && ( reg < 32 ) )
    RB.write( reg, value );
  else
    {
      /* lo, hi */
      if ( ( reg >= 33 ) && ( reg < 35 ) )
        RB.write( reg - 1, value );
      else
        /* pc */
        if ( reg == 37 )
          ac_pc = value;
    }
}


unsigned char mips::mem_read( unsigned int address ) {
  return INST_PORT->read_byte( address );
}


void mips::mem_write( unsigned int address, unsigned char byte ) {
  INST_PORT->write_byte( address, byte );
}
