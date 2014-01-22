
#include "cgstd.h"

#include "cgutil.h"

static string _id(){
	char buf[32];
	static int n_id;
	sprintf( buf,"_%i",++n_id );
	return buf;
}

CGNop *CG::nop(){
	return new CGNop;
}

CGXop *CG::xop( int op,CGReg *r,CGExp *exp ){
	CGXop *t=new CGXop;
	t->op=op;t->def=r;t->exp=exp;
	return t;
}

CGRem *CG::rem( string comment ){
	CGRem *t=new CGRem;
	t->comment=comment;
	return t;
}

CGAti *CG::ati( CGMem *mem ){
	CGAti *t=new CGAti;
	t->mem=mem;
	return t;
}

CGAtd *CG::atd( CGMem *mem,CGSym *sym ){
	CGAtd *t=new CGAtd;
	t->mem=mem;t->sym=sym;
	return t;
}

CGMov *CG::mov( CGExp *lhs,CGExp *rhs ){
	CGMov *t=new CGMov;
	t->lhs=lhs;t->rhs=rhs;
	return t;
}

CGLab *CG::lab( CGSym *sym ){
	CGLab *t=new CGLab;
	t->sym=sym ? sym : CG::sym();
	return t;
}

CGBra *CG::bra( CGSym *sym ){
	CGBra *t=new CGBra;
	t->sym=sym;
	return t;
}

CGBcc *CG::bcc( int cc,CGExp *lhs,CGExp *rhs,CGSym *sym ){
	CGBcc *t=new CGBcc;
	t->cc=cc;t->lhs=lhs;t->rhs=rhs;t->sym=sym;
	return t;
}

CGRet *CG::ret( CGExp *exp ){
	CGRet *t=new CGRet;
	t->exp=exp;
	return t;
}

CGEva *CG::eva( CGExp *exp ){
	CGEva *t=new CGEva;
	t->exp=exp;
	return t;
}

CGSeq *CG::seq( const std::vector<CGStm*> &stms ){
	CGSeq *t=new CGSeq;
	t->stms=stms;
	return t;
}

CGSeq *CG::seq( CGStm *stm0,... ){
	CGSeq *t=new CGSeq;
	if( !stm0 ) return t;
	t->stms.push_back( stm0 );
	va_list args;
	va_start( args,stm0 );
	while( CGStm *p=va_arg(args,CGStm*) ) t->stms.push_back(p);
	return t;
}

CGMem *CG::mem( int type,CGExp *exp,int offset ){
	CGMem *t=new CGMem;
	t->type=type;t->exp=exp;t->offset=offset;t->flags=0;
	return t;
}

CGLea *CG::lea( CGExp *exp ){
	CGLea *t=new CGLea;
	t->type=CG_INT32;t->exp=exp;
	return t;
}

CGCvt *CG::cvt( int type,CGExp *exp ){
	CGCvt *t=new CGCvt;
	t->type=type;t->exp=exp;
	return t;
}

CGUop *CG::uop( int op,CGExp *exp ){
	CGUop *t=new CGUop;
	t->type=exp->type;t->op=op;t->exp=exp;
	return t;
}

CGBop *CG::bop( int op,CGExp *lhs,CGExp *rhs ){
	CGBop *t=new CGBop;
	t->type=lhs->type;t->op=op;t->lhs=lhs;t->rhs=rhs;
	return t;
}

CGJsr *CG::jsr( int type,int call_conv,CGExp *exp,const vector<CGExp*> &args ){
	CGJsr *t=new CGJsr;
	t->type=type;t->call_conv=call_conv;t->exp=exp;t->args=args;
	return t;
}

CGJsr *CG::jsr( int type,int call_conv,CGExp *exp,CGExp *a0,CGExp *a1,CGExp *a2,CGExp *a3 ){
	vector<CGExp*> args;
	if( a0 ) args.push_back(a0);
	if( a1 ) args.push_back(a1);
	if( a2 ) args.push_back(a2);
	if( a3 ) args.push_back(a3);
	return jsr( type,call_conv,exp,args );
}

CGJsr *CG::jsr( int type,string t_sym,const vector<CGExp*> &args ){
	return jsr( type,CG_CDECL,sym(t_sym,CG_IMPORT),args );
}

CGJsr *CG::jsr( int type,string t_sym,CGExp *a0,CGExp *a1,CGExp *a2,CGExp *a3 ){
	vector<CGExp*> args;
	if( a0 ) args.push_back(a0);
	if( a1 ) args.push_back(a1);
	if( a2 ) args.push_back(a2);
	if( a3 ) args.push_back(a3);
	return jsr( type,t_sym,args );
}

CGVfn *CG::vfn( CGExp *exp,CGExp *self ){
	CGVfn *t=new CGVfn;
	t->type=exp->type;t->exp=exp;t->self=self;
	return t;
}

CGScc *CG::scc( int cc,CGExp *lhs,CGExp *rhs ){
	CGScc *t=new CGScc;
	t->type=CG_INT32;t->cc=cc;t->lhs=lhs;t->rhs=rhs;
	return t;
}

CGEsq *CG::esq( CGStm *lhs,CGExp *rhs ){
	CGEsq *t=new CGEsq;
	t->type=rhs->type;t->lhs=lhs;t->rhs=rhs;
	return t;
}

CGFrm *CG::frm(){
	CGFrm *t=new CGFrm;
	t->type=CG_PTR;
	return t;
}

CGLit *CG::lit( int val ){
	CGLit *t=new CGLit;
	t->type=CG_INT32;t->int_value=val;
	return t;
}

CGLit *CG::lit( int64 val ){
	CGLit *t=new CGLit;
	t->type=CG_INT64;t->int_value=val;
	return t;
}

CGLit *CG::lit( float val ){
	CGLit *t=new CGLit;
	t->type=CG_FLOAT32;t->float_value=val;
	return t;
}

CGLit *CG::lit( double val ){
	CGLit *t=new CGLit;
	t->type=CG_FLOAT64;t->float_value=val;
	return t;
}

CGLit *CG::lit( bstring val,int type ){
	CGLit *t=new CGLit;
	t->type=type;t->string_value=val;
	return t;
}

CGTmp *CG::tmp( int type,string id ){
	CGTmp *t=new CGTmp;
	t->type=type;t->ident=id.size() ? id : _id();t->owner=0;
	return t;
}

CGSym *CG::sym(){
	CGSym *t=new CGSym;
	t->type=CG_INT32;
	t->value=_id();
	t->linkage=CG_INTERNAL;
	return t;
}

CGSym *CG::sym( string id,int linkage ){
	CGSym *t=new CGSym;
	t->type=CG_INT32;
	t->value=id;
	t->linkage=linkage;
	return t;
}

CGDat *CG::dat(){
	CGDat *t=new CGDat;
	t->type=CG_INT32;
	t->value=_id();
	t->linkage=CG_INTERNAL;
	return t;
}

CGDat *CG::dat( string id ){
	CGDat *t=new CGDat;
	t->type=CG_INT32;
	t->value=id;
	t->linkage=CG_EXPORT;
	return t;
}

CGFun *CG::fun( int type,int call_conv,CGSym *sym,CGExp *self ){
	CGFun *t=new CGFun;
	t->type=type;t->call_conv=call_conv;t->sym=sym;t->self=self;
	return t;
}

CGFun *CG::visitFun( CGFun *fun,CGVisitor &vis ){

	int k;
	CGFun *out=0;
	bool copy=false;
	vector<CGExp*> args;
	
	CGSym *sym=fun->sym->visit( vis )->sym();
	CGExp *self=fun->self ? fun->self->visit( vis ) : 0;
	if( sym!=fun->sym || self!=fun->self ) copy=true;

	for( k=0;k<fun->args.size();++k ){
		args.push_back( fun->args[k]->visit( vis ) );
		if( args.back()!=fun->args[k] ) copy=true;
	}
	
	CGStm *stm=0;
	
	for( k=0;;++k ){
	
		if( copy ){
			out=CG::fun( fun->type,fun->call_conv,sym,self );
			out->args=args;
			out->stms.reserve( fun->stms.size() );
			for( int j=0;j<k;++j ) out->stms.push_back( fun->stms[j] );
			if( stm ) out->stms[out->stms.size()-1]=stm;
			copy=false;
		}
		
		if( k==fun->stms.size() ) break;
		
		stm=fun->stms[k]->visit( vis );
		
		if( out ){
			out->stms.push_back( stm );
		}else{
			if( stm!=fun->stms[k] ) copy=true;
		}
	}
	
	return out ? out : fun;
}

int CG::swapcc( int cg_cc ){
	switch( cg_cc ){
	case CG_EQ:return CG_NE;
	case CG_NE:return CG_EQ;
	case CG_LT:return CG_GE;
	case CG_GT:return CG_LE;
	case CG_LE:return CG_GT;
	case CG_GE:return CG_LT;
	case CG_LTU:return CG_GEU;
	case CG_GTU:return CG_LEU;
	case CG_LEU:return CG_GTU;
	case CG_GEU:return CG_LTU;
	}
	assert(0);
	return 0;
}

CGLit *CG::lit0=CG::lit(0);
CGLit *CG::lit1=CG::lit(1);
