
#ifndef CGFRAME_X86_H
#define CGFRAME_X86_H

#include "cgframe.h"

struct CGModule_X86;

struct CGFrame_X86 : public CGFrame{

	CGModule_X86 *mod_x86;

	int arg_sz,param_sz,local_sz,tmp_mem,extern_jsrs;

	enum{
		EA_IMM=1,EA_MEM=2
	};
	enum{
		XOP_CDQ=1,XOP_DIV,
		XOP_PUSH4,XOP_PUSH8,XOP_POP
	};
	enum{
		EAX,EDX,ECX,EBX,ESI,EDI,EBP,ESP,
		FP0,FP1,FP2,FP3,FP4,FP5,FP6
	};

	CGReg	*eax,*edx,*ecx,*ebx,*esi,*edi,*ebp,*esp;
	CGReg	*fp0,*fp1,*fp2,*fp3,*fp4,*fp5,*fp6;

	CGMem*	tmpMem( int type );

	CGMem*	optMem( CGMem *exp,char *buf );
	bool	optMov( CGExp *lhs,CGExp *rhs );

	CGMem*	genMem( CGMem *exp,char *buf );
	CGExp*	genExp( CGExp *exp,char *buf,int mask );

	CGReg*	genExp( CGExp *exp );
	CGReg*	genLea( CGLea *exp );
	CGReg*	genCvt( CGCvt *exp );
	CGReg*	genUop( CGUop *exp );
	CGReg*	genBop( CGBop *exp );
	CGReg*	genScc( CGScc *exp );
	CGReg*	genJsr( CGJsr *exp );
	CGReg*	genMacJsr( CGJsr *exp );
	CGReg*	genLit( CGLit *exp );
	CGReg*	genSym( CGSym *exp );
	CGReg*  genFrm( CGFrm *exp );

	CGReg*	genLoad( CGMem *exp );
	void	genStore( CGMem *mem,CGExp *exp );
	void	genCopy( CGReg *res,CGReg *exp );
	void	genMov( CGExp *lhs,CGExp *rhs );

	void	genPush( CGExp *exp );
	void	genPush4( CGExp *exp );
	void	genPush8( CGExp *exp );
	void	genPop( CGExp *exp );

	void	genBcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *sym );
	void	genRet( CGExp *exp );

	void	fixFp();

	CGFrame_X86( CGFun *fun,CGModule_X86 *mod );

	virtual string fixSym( string id );
	virtual void genFun();
	virtual void genStm( CGStm *stm );
	virtual CGMem *allocLocal( int type );
	virtual CGExp *allocSpill( CGReg *r );
	virtual void finish();

	static const char *x86cc( int cg_cc );
	static const char *x86size( int cg_sz );
};

#endif
