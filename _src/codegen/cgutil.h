
#ifndef CGUTIL_H
#define CGUTIL_H

#include "cgcode.h"

namespace CG{
	CGNop*  nop();
	CGXop*	xop( int op,CGReg *def,CGExp *exp );
	CGRem*	rem( string comment );
	CGAti*	ati( CGMem *mem );
	CGAtd*	atd( CGMem *mem,CGSym *sym );
	CGMov*	mov( CGExp *lhs,CGExp *rhs );
	CGLab*	lab( CGSym *sym=0 );
	CGBra*	bra( CGSym *sym );
	CGBcc*	bcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *sym );
	CGRet*	ret( CGExp *exp );
	CGEva*	eva( CGExp *exp );
	CGSeq*	seq( const std::vector<CGStm*> &stms );
	CGSeq*	seq( CGStm *stm0,... );

	CGCvt*	cvt( int type,CGExp *exp );
	CGMem*	mem( int type,CGExp *exp,int offset=0 );
	CGUop*	uop( int op,CGExp *exp );
	CGBop*	bop( int op,CGExp *lhs,CGExp *rhs );
	CGScc*	scc( int cc,CGExp *lhs,CGExp *rhs );
	CGJsr*	jsr( int type,int call_conv,CGExp *exp,const std::vector<CGExp*> &args );
	CGJsr*	jsr( int type,int call_conv,CGExp *exp,CGExp *a0=0,CGExp *a1=0,CGExp *a2=0,CGExp *a3=0 );
	CGJsr*	jsr( int type,string exp,const std::vector<CGExp*> &args );
	CGJsr*	jsr( int type,string exp,CGExp *a0=0,CGExp *a1=0,CGExp *a2=0,CGExp *a3=0 );
	CGVfn*	vfn( CGExp *exp,CGExp *self );
	CGEsq*	esq( CGStm *lhs,CGExp *rhs );
	CGLea*	lea( CGExp *exp );

	CGLit*	lit( int val );
	CGLit*  lit( int64 val );
	CGLit*	lit( float val );
	CGLit*	lit( double val );
	CGLit*  lit( bstring val,int type=CG_BSTRING );
	
	CGFrm*  frm();
	CGSym*  sym();
	CGSym*  sym( string ident,int linkage );
	CGDat*  dat();
	CGDat*  dat( string ident );
	CGTmp*	tmp( int type,string ident="" );

	CGFun*  fun( int type,int call_conv,CGSym *sym,CGExp *self );
	
	CGFun*  visitFun( CGFun *fun,CGVisitor &vis );

	int		swapcc( int cg_cc );
	
	extern  CGLit *lit0,*lit1;
}

#endif