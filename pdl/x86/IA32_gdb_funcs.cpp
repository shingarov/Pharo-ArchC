/**
 * @file      IA32_gdb_funcs.cpp
 * @author    Rodolfo Jardim de Azevedo
 *            Team 03 - MC723 - 2005, 1st period
 *              Eduardo Uemura Okada
 *              Andre Deiano Pansani
 *              Ricardo Andrade
 *
 *            The ArchC Team
 *            http://www.archc.org/
 *
 *            Computer Systems Laboratory (LSC)
 *            IC-UNICAMP
 *            http://www.lsc.ic.unicamp.br
 *
 * @version   1.0
 * @date      Mon, 19 Jun 2006 15:33:29 -0300
 * 
 * @brief     The ArchC x86 functional model.
 * 
 * @attention Copyright (C) 2002-2006 --- The ArchC Team
 *
 */


#include "IA32.H"


#define GENREGS 8
#define SEGREGS 6
#define SPRREGS 2
#define INVALID_REG 0xFFFFFFFF


// Register definitions to register bank GR:8
#define EAX 0
#define ECX 1
#define EDX 2
#define EBX 3
#define ESP 4
#define EBP 5
#define ESI 6
#define EDI 7 
#define AX 0
#define CX 1
#define DX 2
#define BX 3
#define SP 4
#define BP 5
#define SI 6
#define DI 7
#define AL 0
#define CL 1
#define DL 2
#define BL 3
#define AH 4
#define CH 5
#define DH 6
#define BH 7
#define STACK_BOTTOM 0x01000000
// Register definitions to register bank SR:6
#define CS 0
#define DS 1
#define SS 2
#define ES 3
#define FS 4
#define GS 5
// Register definitions to register bank SPR:2
#define EFLAGS 0
#define EIP 1
#define FLAG_CF (1)
#define FLAG_PF (1<<2)
#define FLAG_AF (1<<4)
#define FLAG_ZF (1<<6)
#define FLAG_SF (1<<7)
#define FLAG_TF (1<<8)
#define FLAG_IF (1<<9)
#define FLAG_DF (1<<10)
#define FLAG_OF (1<<11)
#define FLAG_IOPL (1<<12 | 1<<13)
#define FLAG_NT (1<<14)
#define FLAG_RF (1<<16)
#define FLAG_VM (1<<17)
#define FLAG_AC (1<<18)
#define FLAG_VIF (1<<19)
#define FLAG_VIP (1<<20)
#define FLAG_ID (1<<21)
#define FLAG_ALL 0xFFFFFFFF

#define OPERAND_SIZE16JUST 0
#define OPERAND_SIZE16 1
#define OPERAND_SIZE32 2

#define REG_XH 0xFFFF00FF

using namespace IA32_parms;

int OperSize;



int IA32::nRegs(void)
{
  return GENREGS+SEGREGS+SPRREGS;
}

ac_word IA32::reg_read ( int reg )
{
  signed char aux = 0;
  uint GR_temp = 0;

  printf("reg_read %i 0x%08X\n",reg,GR.read(reg));
  if ( (reg >= 0) && (reg < GENREGS) ){
    /*    if (reg == 0){    
      GR_temp = GR[0];//eax
      printf("GR[0]: %08X\n",GR[0]);
      aux = GR[4];//ah
      aux = (aux & 0xFF00);
      //aux = aux << 8;
     
      printf("AUX: %X\n",aux );
      GR_temp = GR_temp & REG_XH;
      printf("GR_temp: %08X\n",GR_temp);
      GR_temp = (GR_temp | aux  );
      printf("EAX: 0x%08X\n",GR_temp);
      return GR_temp;
      }//if*/
    return GR.read(reg);
  }
  else if ( (reg >= GENREGS) && (reg < (GENREGS+SPRREGS)) )
    return SPR.read(1-(reg-(GENREGS)));
  else if ( (reg >= (GENREGS+SPRREGS)) && (reg < (GENREGS+SEGREGS+SPRREGS)) )
    return SR.read(reg-(GENREGS+SPRREGS));
  return INVALID_REG;
}

void IA32::reg_write( int reg, ac_word value )
{
  printf("reg_write\n");
  if ( (reg >= 0) && (reg < GENREGS) )
    //GR.write(reg, value);
    GR.write(reg, value);
  else if ( (reg >= GENREGS) && (reg < (GENREGS+SPRREGS)) )
    SPR.write((1-(reg-GENREGS)), value);
  else if ( (reg >= (GENREGS+SPRREGS)) && (reg < (GENREGS+SEGREGS+SPRREGS)) )
    SR.write((reg-(GENREGS+SPRREGS)), value);
}

unsigned char IA32::mem_read ( unsigned int address )
{
  //return ac_resources::IM->read_byte(address);
  return IM->read_byte(address);
}

void IA32::mem_write ( unsigned int address, unsigned char byte )
{
  //ac_resources::IM->write_byte(address,byte);
  IM->write_byte(address,byte);
}

