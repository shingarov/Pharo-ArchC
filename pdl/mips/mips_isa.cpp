/**
 * @file      mips_isa.cpp
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
 * @brief     The ArchC i8051 functional model.
 * 
 * @attention Copyright (C) 2002-2006 --- The ArchC Team
 *
 */

#include  "mips_isa.H"
#include  "mips_isa_init.cpp"
#include  "mips_bhv_macros.H"


//If you want debug information for this model, uncomment next line
//#define DEBUG_MODEL
#include "ac_debug_model.H"


//!User defined macros to reference registers.
#define Ra 31
#define Sp 29

// 'using namespace' statement to allow access to all
// mips-specific datatypes
using namespace mips_parms;

static int processors_started = 0;
#define DEFAULT_STACK_SIZE (256*1024)

//!Generic instruction behavior method.
void ac_behavior( instruction )
{ 
   dbg_printf("----- PC=%#x ----- %lld\n", (int) ac_pc, ac_instr_counter);
  //  dbg_printf("----- PC=%#x NPC=%#x ----- %lld\n", (int) ac_pc, (int)npc, ac_instr_counter);
#ifndef NO_NEED_PC_UPDATE
  ac_pc = npc;
  npc = ac_pc + 4;
#endif 
};
 
//! Instruction Format behavior methods.
void ac_behavior( Type_R ){}
void ac_behavior( Type_I ){}
void ac_behavior( Type_J ){}
 
//!Behavior called before starting simulation
void ac_behavior(begin)
{
  dbg_printf("@@@ begin behavior @@@\n");
  RB[0] = 0;
  npc = ac_pc + 4;

  // Is is not required by the architecture, but makes debug really easier
  for (int regNum = 0; regNum < 32; regNum ++)
    RB[regNum] = 0;
  hi = 0;
  lo = 0;

  RB[29] =  AC_RAM_END - 1024 - processors_started++ * DEFAULT_STACK_SIZE;
}

//!Behavior called after finishing simulation
void ac_behavior(end)
{
  dbg_printf("@@@ end behavior @@@\n");
}


//!Instruction lb behavior method.
void ac_behavior( lb )
{
  char byte;
  dbg_printf("lb r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  byte = DATA_PORT->read_byte(RB[rs]+ imm);
  RB[rt] = (ac_Sword)byte ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lbu behavior method.
void ac_behavior( lbu )
{
  unsigned char byte;
  dbg_printf("lbu r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  byte = DATA_PORT->read_byte(RB[rs]+ imm);
  RB[rt] = byte ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lh behavior method.
void ac_behavior( lh )
{
  short int half;
  dbg_printf("lh r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  half = DATA_PORT->read_half(RB[rs]+ imm);
  RB[rt] = (ac_Sword)half ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lhu behavior method.
void ac_behavior( lhu )
{
  unsigned short int  half;
  half = DATA_PORT->read_half(RB[rs]+ imm);
  RB[rt] = half ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lw behavior method.
void ac_behavior( lw )
{
  dbg_printf("lw r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  RB[rt] = DATA_PORT->read(RB[rs]+ imm);
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lwl behavior method.
void ac_behavior( lwl )
{
  dbg_printf("lwl r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  unsigned int addr, offset;
  ac_Uword data;

  addr = RB[rs] + imm;
  offset = (addr & 0x3) * 8;
  data = DATA_PORT->read(addr & 0xFFFFFFFC);
  data <<= offset;
  data |= RB[rt] & ((1<<offset)-1);
  RB[rt] = data;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lwr behavior method.
void ac_behavior( lwr )
{
  dbg_printf("lwr r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  unsigned int addr, offset;
  ac_Uword data;

  addr = RB[rs] + imm;
  offset = (3 - (addr & 0x3)) * 8;
  data = DATA_PORT->read(addr & 0xFFFFFFFC);
  data >>= offset;
  data |= RB[rt] & (0xFFFFFFFF << (32-offset));
  RB[rt] = data;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction sb behavior method.
void ac_behavior( sb )
{
  unsigned char byte;
  dbg_printf("sb r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  byte = RB[rt] & 0xFF;
  DATA_PORT->write_byte(RB[rs] + imm, byte);
  dbg_printf("Result = %#x\n", (int) byte);
};

//!Instruction sh behavior method.
void ac_behavior( sh )
{
  unsigned short int half;
  dbg_printf("sh r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  half = RB[rt] & 0xFFFF;
  DATA_PORT->write_half(RB[rs] + imm, half);
  dbg_printf("Result = %#x\n", (int) half);
};

//!Instruction sw behavior method.
void ac_behavior( sw )
{
  dbg_printf("sw r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  DATA_PORT->write(RB[rs] + imm, RB[rt]);
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction swl behavior method.
void ac_behavior( swl )
{
  dbg_printf("swl r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  unsigned int addr, offset;
  ac_Uword data;

  addr = RB[rs] + imm;
  offset = (addr & 0x3) * 8;
  data = RB[rt];
  data >>= offset;
  data |= DATA_PORT->read(addr & 0xFFFFFFFC) & (0xFFFFFFFF << (32-offset));
  DATA_PORT->write(addr & 0xFFFFFFFC, data);
  dbg_printf("Result = %#x\n", data);
};

//!Instruction swr behavior method.
void ac_behavior( swr )
{
  dbg_printf("swr r%d, %d(r%d)\n", rt, imm & 0xFFFF, rs);
  unsigned int addr, offset;
  ac_Uword data;

  addr = RB[rs] + imm;
  offset = (3 - (addr & 0x3)) * 8;
  data = RB[rt];
  data <<= offset;
  data |= DATA_PORT->read(addr & 0xFFFFFFFC) & ((1<<offset)-1);
  DATA_PORT->write(addr & 0xFFFFFFFC, data);
  dbg_printf("Result = %#x\n", data);
};

//!Instruction addi behavior method.
void ac_behavior( addi )
{
  dbg_printf("addi r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  RB[rt] = RB[rs] + imm;
  dbg_printf("Result = %#x\n", RB[rt]);
  //Test overflow
  if ( ((RB[rs] & 0x80000000) == (imm & 0x80000000)) &&
       ((imm & 0x80000000) != (RB[rt] & 0x80000000)) ) {
    fprintf(stderr, "EXCEPTION(addi): integer overflow.\n"); exit(EXIT_FAILURE);
  }
};

//!Instruction addiu behavior method.
void ac_behavior( addiu )
{
  dbg_printf("addiu r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  RB[rt] = RB[rs] + imm;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction slti behavior method.
void ac_behavior( slti )
{
  dbg_printf("slti r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  // Set the RD if RS< IMM
  if( (ac_Sword) RB[rs] < (ac_Sword) imm )
    RB[rt] = 1;
  // Else reset RD
  else
    RB[rt] = 0;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction sltiu behavior method.
void ac_behavior( sltiu )
{
  dbg_printf("sltiu r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  // Set the RD if RS< IMM
  if( (ac_Uword) RB[rs] < (ac_Uword) imm )
    RB[rt] = 1;
  // Else reset RD
  else
    RB[rt] = 0;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction andi behavior method.
void ac_behavior( andi )
{	
  dbg_printf("andi r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  RB[rt] = RB[rs] & (imm & 0xFFFF) ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction ori behavior method.
void ac_behavior( ori )
{	
  dbg_printf("ori r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  RB[rt] = RB[rs] | (imm & 0xFFFF) ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction xori behavior method.
void ac_behavior( xori )
{	
  dbg_printf("xori r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  RB[rt] = RB[rs] ^ (imm & 0xFFFF) ;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction lui behavior method.
void ac_behavior( lui )
{	
  dbg_printf("lui r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  // Load a constant in the upper 16 bits of a register
  // To achieve the desired behaviour, the constant was shifted 16 bits left
  // and moved to the target register ( rt )
  RB[rt] = imm << 16;
  dbg_printf("Result = %#x\n", RB[rt]);
};

//!Instruction add behavior method.
void ac_behavior( add )
{
  dbg_printf("add r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] + RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
  //Test overflow
  if ( ((RB[rs] & 0x80000000) == (RB[rd] & 0x80000000)) &&
       ((RB[rd] & 0x80000000) != (RB[rt] & 0x80000000)) ) {
    fprintf(stderr, "EXCEPTION(add): integer overflow.\n"); exit(EXIT_FAILURE);
  }
};

//!Instruction addu behavior method.
void ac_behavior( addu )
{
  dbg_printf("addu r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] + RB[rt];
  //cout << "  RS: " << (unsigned int)RB[rs] << " RT: " << (unsigned int)RB[rt] << endl;
  //cout << "  Result =  " <<  (unsigned int)RB[rd] <<endl;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction sub behavior method.
void ac_behavior( sub )
{
  dbg_printf("sub r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] - RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
  //TODO: test integer overflow exception for sub
};

//!Instruction subu behavior method.
void ac_behavior( subu )
{
  dbg_printf("subu r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] - RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction slt behavior method.
void ac_behavior( slt )
{	
  dbg_printf("slt r%d, r%d, r%d\n", rd, rs, rt);
  // Set the RD if RS< RT
  if( (ac_Sword) RB[rs] < (ac_Sword) RB[rt] )
    RB[rd] = 1;
  // Else reset RD
  else
    RB[rd] = 0;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction sltu behavior method.
void ac_behavior( sltu )
{
  dbg_printf("sltu r%d, r%d, r%d\n", rd, rs, rt);
  // Set the RD if RS < RT
  if( RB[rs] < RB[rt] )
    RB[rd] = 1;
  // Else reset RD
  else
    RB[rd] = 0;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction instr_and behavior method.
void ac_behavior( instr_and )
{
  dbg_printf("instr_and r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] & RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction instr_or behavior method.
void ac_behavior( instr_or )
{
  dbg_printf("instr_or r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] | RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction instr_xor behavior method.
void ac_behavior( instr_xor )
{
  dbg_printf("instr_xor r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = RB[rs] ^ RB[rt];
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction instr_nor behavior method.
void ac_behavior( instr_nor )
{
  dbg_printf("nor r%d, r%d, r%d\n", rd, rs, rt);
  RB[rd] = ~(RB[rs] | RB[rt]);
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction nop behavior method.
void ac_behavior( nop )
{  
  dbg_printf("nop\n");
};

//!Instruction sll behavior method.
void ac_behavior( sll )
{  
  dbg_printf("sll r%d, r%d, %d\n", rd, rs, shamt);
  RB[rd] = RB[rt] << shamt;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction srl behavior method.
void ac_behavior( srl )
{
  dbg_printf("srl r%d, r%d, %d\n", rd, rs, shamt);
  RB[rd] = RB[rt] >> shamt;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction sra behavior method.
void ac_behavior( sra )
{
  dbg_printf("sra r%d, r%d, %d\n", rd, rs, shamt);
  RB[rd] = (ac_Sword) RB[rt] >> shamt;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction sllv behavior method.
void ac_behavior( sllv )
{
  dbg_printf("sllv r%d, r%d, r%d\n", rd, rt, rs);
  RB[rd] = RB[rt] << (RB[rs] & 0x1F);
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction srlv behavior method.
void ac_behavior( srlv )
{
  dbg_printf("srlv r%d, r%d, r%d\n", rd, rt, rs);
  RB[rd] = RB[rt] >> (RB[rs] & 0x1F);
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction srav behavior method.
void ac_behavior( srav )
{
  dbg_printf("srav r%d, r%d, r%d\n", rd, rt, rs);
  RB[rd] = (ac_Sword) RB[rt] >> (RB[rs] & 0x1F);
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction mult behavior method.
void ac_behavior( mult )
{
  dbg_printf("mult r%d, r%d\n", rs, rt);

  long long result;
  int half_result;

  result = (ac_Sword) RB[rs];
  result *= (ac_Sword) RB[rt];

  half_result = (result & 0xFFFFFFFF);
  // Register LO receives 32 less significant bits
  lo = half_result;

  half_result = ((result >> 32) & 0xFFFFFFFF);
  // Register HI receives 32 most significant bits
  hi = half_result ;

  dbg_printf("Result = %#llx\n", result);
};

//!Instruction multu behavior method.
void ac_behavior( multu )
{
  dbg_printf("multu r%d, r%d\n", rs, rt);

  unsigned long long result;
  unsigned int half_result;

  result  = RB[rs];
  result *= RB[rt];

  half_result = (result & 0xFFFFFFFF);
  // Register LO receives 32 less significant bits
  lo = half_result;

  half_result = ((result>>32) & 0xFFFFFFFF);
  // Register HI receives 32 most significant bits
  hi = half_result ;

  dbg_printf("Result = %#llx\n", result);
};

//!Instruction div behavior method.
void ac_behavior( div )
{
  dbg_printf("div r%d, r%d\n", rs, rt);
  // Register LO receives quotient
  lo = (ac_Sword) RB[rs] / (ac_Sword) RB[rt];
  // Register HI receives remainder
  hi = (ac_Sword) RB[rs] % (ac_Sword) RB[rt];
};

//!Instruction divu behavior method.
void ac_behavior( divu )
{
  dbg_printf("divu r%d, r%d\n", rs, rt);
  // Register LO receives quotient
  lo = RB[rs] / RB[rt];
  // Register HI receives remainder
  hi = RB[rs] % RB[rt];
};

//!Instruction mfhi behavior method.
void ac_behavior( mfhi )
{
  dbg_printf("mfhi r%d\n", rd);
  RB[rd] = hi;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction mthi behavior method.
void ac_behavior( mthi )
{
  dbg_printf("mthi r%d\n", rs);
  hi = RB[rs];
  dbg_printf("Result = %#x\n", (unsigned int) hi);
};

//!Instruction mflo behavior method.
void ac_behavior( mflo )
{
  dbg_printf("mflo r%d\n", rd);
  RB[rd] = lo;
  dbg_printf("Result = %#x\n", RB[rd]);
};

//!Instruction mtlo behavior method.
void ac_behavior( mtlo )
{
  dbg_printf("mtlo r%d\n", rs);
  lo = RB[rs];
  dbg_printf("Result = %#x\n", (unsigned int) lo);
};

//!Instruction j behavior method.
void ac_behavior( j )
{
  dbg_printf("j %d\n", addr);
  addr = addr << 2;
#ifndef NO_NEED_PC_UPDATE
  npc =  (ac_pc & 0xF0000000) | addr;
#endif 
  dbg_printf("Target = %#x\n", (ac_pc & 0xF0000000) | addr );
};

//!Instruction jal behavior method.
void ac_behavior( jal )
{
  dbg_printf("jal %d\n", addr);
  // Save the value of PC + 8 (return address) in $ra ($31) and
  // jump to the address given by PC(31...28)||(addr<<2)
  // It must also flush the instructions that were loaded into the pipeline
  RB[Ra] = ac_pc+4; //ac_pc is pc+4, we need pc+8
	
  addr = addr << 2;
#ifndef NO_NEED_PC_UPDATE
  npc = (ac_pc & 0xF0000000) | addr;
#endif 
	
  dbg_printf("Target = %#x\n", (ac_pc & 0xF0000000) | addr );
  dbg_printf("Return = %#x\n", ac_pc+4);
};

//!Instruction jr behavior method.
void ac_behavior( jr )
{
  dbg_printf("jr r%d\n", rs);
  // Jump to the address stored on the register reg[RS]
  // It must also flush the instructions that were loaded into the pipeline
#ifndef NO_NEED_PC_UPDATE
  npc = RB[rs], (void) 1;
#endif 
  dbg_printf("Target = %#x\n", RB[rs]);
};

//!Instruction jalr behavior method.
void ac_behavior( jalr )
{
  dbg_printf("jalr r%d, r%d\n", rd, rs);
  // Save the value of PC + 8(return address) in rd and
  // jump to the address given by [rs]

#ifndef NO_NEED_PC_UPDATE
  npc = RB[rs], (void) 1;
#endif 
  dbg_printf("Target = %#x\n", RB[rs]);

  if( rd == 0 )  //If rd is not defined use default
    rd = Ra;
  RB[rd] = ac_pc+4;
  dbg_printf("Return = %#x\n", ac_pc+4);
};

//!Instruction beq behavior method.
void ac_behavior( beq )
{
  dbg_printf("beq r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  if( RB[rs] == RB[rt] ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction bne behavior method.
void ac_behavior( bne )
{	
  dbg_printf("bne r%d, r%d, %d\n", rt, rs, imm & 0xFFFF);
  if( RB[rs] != RB[rt] ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction blez behavior method.
void ac_behavior( blez )
{
  dbg_printf("blez r%d, %d\n", rs, imm & 0xFFFF);
  if( (RB[rs] == 0 ) || (RB[rs]&0x80000000 ) ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2), (void) 1;
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction bgtz behavior method.
void ac_behavior( bgtz )
{
  dbg_printf("bgtz r%d, %d\n", rs, imm & 0xFFFF);
  if( !(RB[rs] & 0x80000000) && (RB[rs]!=0) ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction bltz behavior method.
void ac_behavior( bltz )
{
  dbg_printf("bltz r%d, %d\n", rs, imm & 0xFFFF);
  if( RB[rs] & 0x80000000 ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction bgez behavior method.
void ac_behavior( bgez )
{
  dbg_printf("bgez r%d, %d\n", rs, imm & 0xFFFF);
  if( !(RB[rs] & 0x80000000) ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
};

//!Instruction bltzal behavior method.
void ac_behavior( bltzal )
{
  dbg_printf("bltzal r%d, %d\n", rs, imm & 0xFFFF);
  RB[Ra] = ac_pc+4; //ac_pc is pc+4, we need pc+8
  if( RB[rs] & 0x80000000 ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
  dbg_printf("Return = %#x\n", ac_pc+4);
};

//!Instruction bgezal behavior method.
void ac_behavior( bgezal )
{
  dbg_printf("bgezal r%d, %d\n", rs, imm & 0xFFFF);
  RB[Ra] = ac_pc+4; //ac_pc is pc+4, we need pc+8
  if( !(RB[rs] & 0x80000000) ){
#ifndef NO_NEED_PC_UPDATE
    npc = ac_pc + (imm<<2);
#endif 
    dbg_printf("Taken to %#x\n", ac_pc + (imm<<2));
  }	
  dbg_printf("Return = %#x\n", ac_pc+4);
};

//!Instruction sys_call behavior method.
void ac_behavior( sys_call )
{
  dbg_printf("syscall\n");
  stop();
}

//!Instruction instr_break behavior method.
void ac_behavior( instr_break )
{
  fprintf(stderr, "instr_break behavior not implemented.\n"); 
  exit(EXIT_FAILURE);
}
