
#ifndef CGFRAME_PPC_H
#define CGFRAME_PPC_H

#include "cgframe.h"

struct CGModule_PPC;

struct CGFrame_PPC : public CGFrame{

	CGModule_PPC *mod_ppc;

	int		param_sz,local_sz,tmp_disp8,bigFun;

	CGReg*	R[32];
	CGReg*	F[32];
	
	enum{
		EA_SIMM=1,
		EA_UIMM=2,
		EA_SHIFTED=4
	};
	enum{
		XOP_LWARX,
		XOP_STWCX
	};

	CGMem*	genMem( CGMem *exp,char *buf );

	CGReg*	genExp( CGExp *exp );
	CGReg*	genLea( CGLea *exp );
	CGReg*	genCvt( CGCvt *exp );
	CGReg*	genUop( CGUop *exp );
	CGReg*	genBop( CGBop *exp );
	CGReg*	genScc( CGScc *exp );
	CGReg*	genJsr( CGJsr *exp );
	CGReg*	genLit( CGLit *exp );
	CGReg*	genSym( CGSym *exp );
	CGReg*  genFrm( CGFrm *exp );
	
	CGExp*  genExp( CGExp *exp,char *buf,int &ea_mask );

	CGReg*  genLoad( CGMem *mem );
	void	genStore( CGMem *mem,CGExp *exp );
	void	genCopy( CGReg *dst,CGReg *src );
	void	genMov( CGExp *lhs,CGExp *rhs );
	void	genBcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *sym );
	void	genRet( CGExp *exp );
	
	CGFrame_PPC( CGFun *fun,CGModule_PPC *mod );

	virtual string  fixSym( string id );
	virtual void	genFun();
	virtual void	genStm( CGStm *stm );
	virtual CGMem*  allocLocal( int type );
	virtual CGExp*  allocSpill( CGReg *r );
	virtual void	finish();
};

#endif
