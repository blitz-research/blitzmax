
#ifndef CGFRAME_H
#define CGFRAME_H

#include "cgflow.h"

struct CGFrame{
	CGFun*		fun;
	CGFlow*		flow;
	CGAsmSeq	assem;
	CGAsm*		asm_it;
	CGReg*		int64ret;
	bool		big_endian,little_endian;
	
	int			reg_banks[8];		//maps types->banks
	int			reg_masks[4];		//usable regs per bank
	vector<const char*>  reg_names[4];   //reg names per bank
	
	vector<CGReg*> regs;
	map<string,CGExp*> tmps;
	
	CGFrame( CGFun *fun );
	virtual ~CGFrame();
	
	//before ASM is generated
	void		findEscapes();		//local escaping tmps
	void		renameTmps();		//rename tmps->regs
	void		fixInt64();
	void		linearize();		//remove SEQ and ESQ nodes
	void		fixSymbols();		//fix symbols depending on platform
	void		preOptimize();		//do some opts before asm gen
	
	//generate ASM
	void		genAssem();			//create assem from fun
	void		createFlow();		//create flowgraph
	
	//optimize FlowGraph
	void		optDeadCode();		//eliminate dead code
	void		optDupLoads();		//eliminate extra 'loads'
	
	//assign regs/rewrite src
	void		allocRegs();		//alloc registers
	void		spillReg( CGReg *r,CGExp *e );

	void		deleteFlow();
	void		peepOpt();

	CGMem*		int64el( CGMem *i64,int n );
	CGMem*		int64lo( CGMem *i64 );
	CGMem*		int64hi( CGMem *i64 );
	
	CGReg*		reg( int type,CGReg *owner=0,int color=-1 );
	CGAsm*		gen( CGStm *stm,const char *fmt,... );

	virtual string  fixSym( string id )=0;
	virtual void	genFun()=0;
	virtual void	genStm( CGStm *stm )=0;
	virtual CGMem*  allocLocal( int type )=0;
	virtual CGExp*  allocSpill( CGReg *r )=0;
	virtual void	finish()=0;
};

#endif