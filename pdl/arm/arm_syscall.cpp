/**
 * @file      arm_syscall.cpp
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

#include "arm_syscall.H"

using namespace arm_parms;

void arm_syscall::get_buffer(int argn, unsigned char* buf, unsigned int size) {
  unsigned int addr = RB.read(argn);

  for (unsigned int i = 0; i<size; i++, addr++) {
    buf[i] = DATA_PORT->read_byte(addr);
  }
}

void arm_syscall::guest2hostmemcpy(unsigned char *dst, uint32_t src,
                                   unsigned int size) {
  for (unsigned int i = 0; i < size; i++) {
    dst[i] = DATA_PORT->read_byte(src++);
  }
}

void arm_syscall::set_buffer(int argn, unsigned char* buf, unsigned int size) {
  unsigned int addr = RB.read(argn);

  for (unsigned int i = 0; i<size; i++, addr++) {
     DATA_PORT->write_byte(addr, buf[i]);
     //printf("\nMEM[%d]=%d", addr, buf[i]);
  }
}

void arm_syscall::host2guestmemcpy(uint32_t dst, unsigned char *src,
                                   unsigned int size) {
  for (unsigned int i = 0; i < size; i++) {
    DATA_PORT->write_byte(dst++, src[i]);
  }
}

void arm_syscall::set_buffer_noinvert(int argn, unsigned char* buf, unsigned int size) {
  unsigned int addr = RB.read(argn);

  for (unsigned int i = 0; i<size; i+=4, addr+=4) {
    DATA_PORT->write(addr, *(unsigned int *) &buf[i]);
  }
}

void arm_syscall::set_pc(unsigned val) {
  RB.write(15, val);
  ac_pc.write(val);
}
 
void arm_syscall::set_return(unsigned val) {
  RB.write(14, val);
}
 
unsigned arm_syscall::get_return() {
  return (unsigned) RB.read(14);
}

int arm_syscall::get_int(int argn) {
  return RB.read(argn);
}

void arm_syscall::set_int(int argn, int val) {
  RB.write(argn, val);
}

void arm_syscall::return_from_syscall() {
  ac_pc = RB.read(14);
}

bool arm_syscall::is_mmap_anonymous(uint32_t flags) {
  return flags & 0x20;
}

void arm_syscall::set_prog_args(int argc, char **argv) {
  int i, j, base;

  unsigned int ac_argv[30];
  char ac_argstr[512];

  base = AC_RAM_END - 512;

  
  for (i=0, j=0; i<argc; i++) {
    int len = strlen(argv[i]) + 1;
    ac_argv[i] = base + j;
    memcpy(&ac_argstr[j], argv[i], len);
    j += len;
  }
  //Write zero at the end of argv, and sets env to NULL (no
  //environmental variables are available)
  ac_argv[argc] = 0;
  ac_argv[argc+1] = 0;

  //Ajust %sp and write argument string
  RB.write(0, AC_RAM_END-512);
  set_buffer(0, (unsigned char*) ac_argstr, 512);

  //Ajust %sp and write string pointers
  RB.write(0, AC_RAM_END-512-120);
  set_buffer_noinvert(0, (unsigned char*) ac_argv, 120);

  if (ref.ac_dyn_loader.is_glibc()) {
    //Put argc into stack (required by glibc)
    RB.write(13, AC_RAM_END-512-124);
    DATA_PORT->write(AC_RAM_END-512-124, argc);
  }

  if (ref.ac_dyn_loader.get_init_arraysz() != 0) {
    set_return(0x80);
  }

  if (ref.ac_dyn_loader.is_glibc()) {

    //Set a1 to our finalization hook
    RB.write(0, 0x84);

  } else {
    /* Configure for newlib with libac_sysc */
    //Set a1 to argument count
    RB.write(0, argc);

    //Set a2 to the string pointers
    RB.write(1, AC_RAM_END-512-120);
  }

}


#define ARM__NR_SYSCALL_BASE	0x900000

#define ARM__NR_restart_syscall		(ARM__NR_SYSCALL_BASE+  0)
#define ARM__NR_exit			(ARM__NR_SYSCALL_BASE+  1)
#define ARM__NR_fork			(ARM__NR_SYSCALL_BASE+  2)
#define ARM__NR_read			(ARM__NR_SYSCALL_BASE+  3)
#define ARM__NR_write			(ARM__NR_SYSCALL_BASE+  4)
#define ARM__NR_open			(ARM__NR_SYSCALL_BASE+  5)
#define ARM__NR_close			(ARM__NR_SYSCALL_BASE+  6)
#define ARM__NR_creat			(ARM__NR_SYSCALL_BASE+  8)
#define ARM__NR_time			(ARM__NR_SYSCALL_BASE+ 13)
#define ARM__NR_lseek			(ARM__NR_SYSCALL_BASE+ 19)
#define ARM__NR_getpid			(ARM__NR_SYSCALL_BASE+ 20)
#define ARM__NR_access			(ARM__NR_SYSCALL_BASE+ 33)
#define ARM__NR_kill			(ARM__NR_SYSCALL_BASE+ 37)
#define ARM__NR_dup			(ARM__NR_SYSCALL_BASE+ 41)
#define ARM__NR_times			(ARM__NR_SYSCALL_BASE+ 43)
#define ARM__NR_brk			(ARM__NR_SYSCALL_BASE+ 45)
#define ARM__NR_gettimeofday		(ARM__NR_SYSCALL_BASE+ 78)
#define ARM__NR_settimeofday		(ARM__NR_SYSCALL_BASE+ 79)
#define ARM__NR_mmap			(ARM__NR_SYSCALL_BASE+ 90)
#define ARM__NR_munmap			(ARM__NR_SYSCALL_BASE+ 91)
#define ARM__NR_socketcall		(ARM__NR_SYSCALL_BASE+102)
#define ARM__NR_stat			(ARM__NR_SYSCALL_BASE+106)
#define ARM__NR_lstat			(ARM__NR_SYSCALL_BASE+107)
#define ARM__NR_fstat			(ARM__NR_SYSCALL_BASE+108)
#define ARM__NR_uname			(ARM__NR_SYSCALL_BASE+122)
#define ARM__NR__llseek			(ARM__NR_SYSCALL_BASE+140)
#define ARM__NR_readv			(ARM__NR_SYSCALL_BASE+145)
#define ARM__NR_writev			(ARM__NR_SYSCALL_BASE+146)
#define ARM__NR_mmap2			(ARM__NR_SYSCALL_BASE+192)
#define ARM__NR_stat64			(ARM__NR_SYSCALL_BASE+195)
#define ARM__NR_lstat64			(ARM__NR_SYSCALL_BASE+196)
#define ARM__NR_fstat64			(ARM__NR_SYSCALL_BASE+197)
#define ARM__NR_getuid32		(ARM__NR_SYSCALL_BASE+199)
#define ARM__NR_getgid32		(ARM__NR_SYSCALL_BASE+200)
#define ARM__NR_geteuid32		(ARM__NR_SYSCALL_BASE+201)
#define ARM__NR_getegid32		(ARM__NR_SYSCALL_BASE+202)
#define ARM__NR_fcntl64			(ARM__NR_SYSCALL_BASE+221)
#define ARM__NR_exit_group	        (ARM__NR_SYSCALL_BASE+248)


int *arm_syscall::get_syscall_table() {
  static int syscall_table[] = {
    ARM__NR_restart_syscall,
    ARM__NR_exit,
    ARM__NR_fork,
    ARM__NR_read,
    ARM__NR_write,
    ARM__NR_open,
    ARM__NR_close,
    ARM__NR_creat,
    ARM__NR_time,
    ARM__NR_lseek,
    ARM__NR_getpid,
    ARM__NR_access,
    ARM__NR_kill,
    ARM__NR_dup,
    ARM__NR_times,
    ARM__NR_brk,
    ARM__NR_mmap,
    ARM__NR_munmap,
    ARM__NR_stat,
    ARM__NR_lstat,
    ARM__NR_fstat,
    ARM__NR_uname,
    ARM__NR__llseek,
    ARM__NR_readv,
    ARM__NR_writev,
    ARM__NR_mmap2,
    ARM__NR_stat64,
    ARM__NR_lstat64,
    ARM__NR_fstat64,
    ARM__NR_getuid32,
    ARM__NR_getgid32,
    ARM__NR_geteuid32,
    ARM__NR_getegid32,
    ARM__NR_fcntl64,
    ARM__NR_exit_group,
    ARM__NR_socketcall,
    ARM__NR_gettimeofday,
    ARM__NR_settimeofday,
    666  /* clock_gettime = unavailable */
  };
  return syscall_table;
}
