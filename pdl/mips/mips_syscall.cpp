/**
 * @file      mips_syscall.cpp
 * @author    Sandro Rigo
 *            Marcus Bartholomeu
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
 * This program is free software; you can redistribute it and/or modify 
 * it under the terms of the GNU General Public License as published by 
 * the Free Software Foundation; either version 2 of the License, or 
 * (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 * GNU General Public License for more details. 
 * 
 * You should have received a copy of the GNU General Public License 
 * along with this program; if not, write to the Free Software 
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include "mips_syscall.H"

// 'using namespace' statement to allow access to all
// mips-specific datatypes
using namespace mips_parms;
unsigned procNumber = 0;

void mips_syscall::get_buffer(int argn, unsigned char* buf, unsigned int size)
{
  unsigned int addr = RB[4+argn];

  for (unsigned int i = 0; i<size; i++, addr++) {
    buf[i] = DATA_PORT->read_byte(addr);
  }
}

void mips_syscall::set_buffer(int argn, unsigned char* buf, unsigned int size)
{
  unsigned int addr = RB[4+argn];

  for (unsigned int i = 0; i<size; i++, addr++) {
    DATA_PORT->write_byte(addr, buf[i]);
    //printf("\nDATA_PORT[%d]=%d", addr, buf[i]);

  }
}

void mips_syscall::set_buffer_noinvert(int argn, unsigned char* buf, unsigned int size)
{
  unsigned int addr = RB[4+argn];

  for (unsigned int i = 0; i<size; i+=4, addr+=4) {
    DATA_PORT->write(addr, *(unsigned int *) &buf[i]);
    //printf("\nDATA_PORT_no[%d]=%d", addr, buf[i]);
  }
}

int mips_syscall::get_int(int argn)
{
  return RB[4+argn];
}

void mips_syscall::set_int(int argn, int val)
{
  RB[2+argn] = val;
}

void mips_syscall::return_from_syscall()
{
  ac_pc = RB[31];
  npc = ac_pc + 4;
}

void mips_syscall::set_prog_args(int argc, char **argv)
{


  int i, j, base;

  unsigned int ac_argv[30];
  char ac_argstr[512];

  base = AC_RAM_END - 512 - procNumber * 64 * 1024;
  for (i=0, j=0; i<argc; i++) {
    int len = strlen(argv[i]) + 1;
    ac_argv[i] = base + j;
    memcpy(&ac_argstr[j], argv[i], len);
    j += len;
  }

  RB[4] = base;
  set_buffer(0, (unsigned char*) ac_argstr, 512);   //$25 = $29(sp) - 4 (set_buffer adds 4)
  

  RB[4] = base - 120;
  set_buffer_noinvert(0, (unsigned char*) ac_argv, 120);

  //RB[4] = AC_RAM_END-512-128;

  //Set %o0 to the argument count
  RB[4] = argc;

  //Set %o1 to the string pointers
  RB[5] = base - 120;

  procNumber ++;
}



