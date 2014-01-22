
#include "cgstd.h"

#include "cgcode.h"
#include "cgutil.h"

CGStm *CGVisitor::visit( CGStm *t ){
	return t;
}

CGExp *CGVisitor::visit( CGExp *e ){
	return e;
}

CGNop *CGStm::nop(){ return 0; }
CGXop *CGStm::xop(){ return 0; }
CGRem *CGStm::rem(){ return 0; }
CGAti *CGStm::ati(){ return 0; }
CGAtd *CGStm::atd(){ return 0; }
CGMov *CGStm::mov(){ return 0; }
CGLab *CGStm::lab(){ return 0; }
CGBra *CGStm::bra(){ return 0; }
CGBcc *CGStm::bcc(){ return 0; }
CGEva *CGStm::eva(){ return 0; }
CGRet *CGStm::ret(){ return 0; }
CGSeq *CGStm::seq(){ return 0; }

CGMem *CGExp::mem(){ return 0; }
CGLea *CGExp::lea(){ return 0; }
CGCvt *CGExp::cvt(){ return 0; }
CGUop *CGExp::uop(){ return 0; }
CGBop *CGExp::bop(){ return 0; }
CGJsr *CGExp::jsr(){ return 0; }
CGVfn *CGExp::vfn(){ return 0; }
CGScc *CGExp::scc(){ return 0; }
CGEsq *CGExp::esq(){ return 0; }
CGFrm *CGExp::frm(){ return 0; }
CGTmp *CGExp::tmp(){ return 0; }
CGLit *CGExp::lit(){ return 0; }
CGSym *CGExp::sym(){ return 0; }
CGDat *CGExp::dat(){ return 0; }
CGReg *CGExp::reg(){ return 0; }

CGStm::~CGStm(){
}

CGStm *CGStm::visit( CGVisitor &vis ){
	assert(0);
	return 0;
}

CGExp *CGExp::nonEsq(){
	return this;
}

CGExp *CGExp::visit( CGVisitor &vis ){
	assert(0);
	return 0;
}

CGExp::~CGExp(){
}

bool CGExp::sideEffects(){
	return false;
}

bool CGExp::equals( CGExp *exp ){
	return false;
}

//***** CGNop *****
CGNop *CGNop::nop(){
	return this;
}

CGStm *CGNop::visit( CGVisitor &vis ){
	return vis.visit( this );
}

//***** CGXop *****
CGXop *CGXop::xop(){
	return this;
}

CGStm *CGXop::visit( CGVisitor &vis ){
	CGReg *r=def ? vis.visit(def)->reg() : 0;
	CGExp *e=exp ? exp->visit(vis) : 0;
	return vis.visit( r==def && e==exp ? this : CG::xop(op,r,e) );
}

//***** CGRem *****
CGRem *CGRem::rem(){
	return this;
}

CGStm *CGRem::visit( CGVisitor &vis ){
	return vis.visit( this );
}

//***** CGAti *****
CGAti *CGAti::ati(){
	return this;
}

CGStm *CGAti::visit( CGVisitor &vis ){
	CGMem *e=mem->visit(vis)->mem();
	return vis.visit( e==mem ? this : CG::ati(e) );
}

//***** CGAtd *****
CGAtd *CGAtd::atd(){
	return this;
}

CGStm *CGAtd::visit( CGVisitor &vis ){
	CGMem *a=mem->visit(vis)->mem();
	CGSym *b=sym->visit(vis)->sym();
	return vis.visit( a==mem && b==sym ? this : CG::atd(a,b) );
}

//***** CGMov *****
CGMov *CGMov::mov(){
	return this;
}

CGStm *CGMov::visit( CGVisitor &vis ){
	CGExp *b=rhs->visit(vis);
	CGExp *a=lhs->visit(vis);
	return vis.visit( a==lhs && b==rhs ? this : CG::mov(a,b) );
}

//***** CGLab *****
CGLab *CGLab::lab(){
	return this;
}

CGStm *CGLab::visit( CGVisitor &vis ){
	CGSym *e=vis.visit(sym)->sym();
	return vis.visit( e==sym ? this : CG::lab(e) );
}

//***** CGBra *****
CGBra *CGBra::bra(){
	return this;
}

CGStm *CGBra::visit( CGVisitor &vis ){
	CGSym *e=vis.visit(sym)->sym();
	return vis.visit( e==sym ? this : CG::bra(e) );
}

//***** CGBcc *****
CGBcc *CGBcc::bcc(){
	return this;
}

CGStm *CGBcc::visit( CGVisitor &vis ){
	CGExp *a=lhs->visit(vis);
	CGExp *b=rhs->visit(vis);
	CGSym *c=vis.visit(sym)->sym();
	return vis.visit( a==lhs && b==rhs && c==sym ? this : CG::bcc(cc,a,b,c) );
}

//***** CGEva *****
CGEva *CGEva::eva(){
	return this;
}

CGStm *CGEva::visit( CGVisitor &vis ){
	CGExp *e=exp->visit(vis);
	return vis.visit( e==exp ? this : CG::eva(e) );
}

//***** CGRet *****
CGRet *CGRet::ret(){
	return this;
}

CGStm *CGRet::visit( CGVisitor &vis ){
	CGExp *e=exp ? exp->visit(vis) : 0;
	return vis.visit( e==exp ? this : CG::ret(e) );
}

//***** CGSeq *****
CGSeq *CGSeq::seq(){
	return this;
}

CGStm *CGSeq::visit( CGVisitor &vis ){
	bool dup=false;
	vector<CGStm*> t_stms;
	int i;
	for( i=0;i<stms.size();++i ){
		CGStm *t=stms[i]->visit(vis);
		if( t!=stms[i] ) dup=true;
		t_stms.push_back( t );
	}
	return vis.visit( dup ? CG::seq( t_stms ) : this );
}

void CGSeq::push_back( CGStm *stm ){
	stms.push_back( stm );
}

void CGSeq::push_front( CGStm *stm ){
	stms.insert( stms.begin(),stm );
}

//***** CGMem *****
CGMem *CGMem::mem(){
	return this;
}

bool CGMem::sideEffects(){
	return exp->sideEffects();
}

bool CGMem::equals( CGExp *e ){
	CGMem *t=e->mem();
	if( !t || type!=t->type || offset!=t->offset || flags!=t->flags ) return false;
	return exp->equals(t->exp);
}

CGExp *CGMem::visit( CGVisitor &vis ){
	CGExp *e=exp->visit(vis);
	return vis.visit( e==exp ? this : CG::mem(type,e,offset) );
}

//***** CGLea *****
CGLea *CGLea::lea(){
	return this;
}

bool CGLea::sideEffects(){
	return exp->sideEffects();
}

bool CGLea::equals( CGExp *e ){
	CGLea *t=e->lea();
	if( !t || type!=t->type ) return false;
	return exp->equals(t->exp);
}

CGExp *CGLea::visit( CGVisitor &vis ){
	CGExp *e=exp->visit(vis);
	return vis.visit( e==exp ? this : CG::lea(e) );
}

//***** CGCvt *****
CGCvt *CGCvt::cvt(){
	return this;
}

bool CGCvt::sideEffects(){
	return exp->sideEffects();
}

bool CGCvt::equals( CGExp *e ){
	CGCvt *t=e->cvt();
	if( !t || type!=t->type ) return false;
	return exp->equals(t->exp);
}

CGExp *CGCvt::visit( CGVisitor &vis ){
	CGExp *e=exp->visit(vis);
	return vis.visit( e==exp ? this : CG::cvt(type,e) );
}

//***** CGUop *****
CGUop *CGUop::uop(){
	return this;
}

bool CGUop::sideEffects(){
	return exp->sideEffects();
}

bool CGUop::equals( CGExp *e ){
	CGUop *t=e->uop();
	return t && type==t->type && exp->equals(t->exp);
}

CGExp *CGUop::visit( CGVisitor &vis ){
	CGExp *e=exp->visit(vis);
	return vis.visit( e==exp ? this : CG::uop(op,e) );
}

//***** CGBop *****
CGBop *CGBop::bop(){
	return this;
}

bool CGBop::commutes(){
	switch(op){
	case CG_ADD:case CG_MUL:case CG_AND:case CG_ORL:case CG_XOR:
		return true;
	}
	return false;
}

bool CGBop::sideEffects(){
	return lhs->sideEffects() || rhs->sideEffects();
}

bool CGBop::equals( CGExp *e ){
	CGBop *t=e->bop();
	if( !t || type!=t->type || op!=t->op ) return false;
	if( lhs->equals(t->lhs) && rhs->equals(t->rhs) ) return true;
	switch(op){
	case CG_ADD:case CG_MUL:break;
	default:return false;
	}
	return lhs->equals(t->rhs) && rhs->equals(t->lhs);
}

CGExp *CGBop::visit( CGVisitor &vis ){
	CGExp *a=lhs->visit(vis);
	CGExp *b=rhs->visit(vis);
	return vis.visit( a==lhs && b==rhs ? this : CG::bop(op,a,b) );
}

//***** CGJsr *****
CGJsr *CGJsr::jsr(){
	return this;
}

bool CGJsr::sideEffects(){
	return true;
}

bool CGJsr::equals( CGExp *e ){
	CGJsr *t=e->jsr();
	if( !t || type!=t->type || args.size()!=t->args.size() ) return false;
	if( exp->equals(t->exp) ) return false;
	for( int k=0;k<args.size();++k ){
		if( !args[k]->equals(t->args[k]) ) return false;
	}
	return true;
}

CGExp *CGJsr::visit( CGVisitor &vis ){
	CGExp *t_exp=exp->visit(vis);
	bool copy=t_exp!=exp;
	vector<CGExp*> t_args;
	t_args.resize(args.size());
	for( int k=0;k<args.size();++k ){
		t_args[k]=args[k]->visit(vis);
		if( t_args[k]!=args[k] ) copy=true;
	}
	if( !copy ) return vis.visit( this );
	CGJsr *t=CG::jsr(type,call_conv,t_exp,t_args );
	return vis.visit( t );
}

//***** CGVfn *****
CGVfn *CGVfn::vfn(){
	return this;
}

bool CGVfn::sideEffects(){
	return exp->sideEffects() || self->sideEffects();
}

bool CGVfn::equals( CGExp *e ){
	CGVfn *t=e->vfn();
	if( !t || type!=t->type ) return false;
	return exp->equals(t->exp) && self->equals(t->self);
}

CGExp *CGVfn::visit( CGVisitor &vis ){
	CGExp *a=exp->visit(vis);
	CGExp *b=self->visit(vis);
	return vis.visit( a==exp && b==self ? this : CG::vfn(a,b) );
}

//***** CGScc *****
CGScc *CGScc::scc(){
	return this;
}

bool CGScc::sideEffects(){
	return lhs->sideEffects() || rhs->sideEffects();
}

bool CGScc::equals( CGExp *e ){
	CGScc *t=e->scc();
	if( !t || type!=t->type || cc!=t->cc ) return false;
	return lhs->equals(t->lhs) && rhs->equals(t->rhs);
}

CGExp *CGScc::visit( CGVisitor &vis ){
	CGExp *a=lhs->visit(vis);
	CGExp *b=rhs->visit(vis);
	return vis.visit( a==lhs && b==rhs ? this : CG::scc(cc,a,b) );
}

//***** CGEsq *****
CGEsq *CGEsq::esq(){
	return this;
}

CGExp *CGEsq::nonEsq(){
	return rhs->nonEsq();
}

bool CGEsq::sideEffects(){
	return true;
}

bool CGEsq::equals( CGExp *e ){
	CGEsq *t=e->esq();
	if( !t || type!=t->type ) return false;
	return rhs->equals(t->rhs);
}

CGExp *CGEsq::visit( CGVisitor &vis ){
	CGStm *a=lhs->visit(vis);
	CGExp *b=rhs->visit(vis);
	return vis.visit( a==lhs && b==rhs ? this : CG::esq(a,b) );
}

//***** CGFrm *****
CGFrm *CGFrm::frm(){
	return this;
}

bool CGFrm::equals( CGExp *e ){
	return e->frm() ? true : false;
}

CGExp *CGFrm::visit( CGVisitor &vis ){
	return vis.visit(this);
}

//***** CGTmp *****
CGTmp *CGTmp::tmp(){
	return this;
}

bool CGTmp::equals( CGExp *e ){
	CGTmp *t=e->tmp();
	if( !t || type!=t->type ) return false;
	return ident==t->ident;
}

CGExp *CGTmp::visit( CGVisitor &vis ){
	return vis.visit(this);
}

//***** CGReg *****
CGReg *CGReg::reg(){
	return this;
}

bool CGReg::equals( CGExp *e ){
	CGReg *t=e->reg();
	return t ? id==t->id : false;
}

CGExp *CGReg::visit( CGVisitor &vis ){
	return vis.visit(this);
}

//***** CGLit *****
CGLit *CGLit::lit(){
	return this;
}

bool CGLit::equals( CGExp *e ){
	CGLit *t=e->lit();
	if( !t || type!=t->type ) return false;
	if( isfloat() ) return float_value==t->float_value;
	return int_value==t->int_value;
}

CGExp *CGLit::visit( CGVisitor &vis ){
	return vis.visit(this);
}

//***** CGSym *****
CGSym *CGSym::sym(){
	return this;
}

bool CGSym::equals( CGExp *e ){
	CGSym *t=e->sym();
	return t && value==t->value && linkage==t->linkage;
}

CGExp *CGSym::visit( CGVisitor &vis ){
	return vis.visit(this);
}

//***** CGDat *****
CGDat *CGDat::dat(){
	return this;
}

bool CGDat::equals( CGExp *e ){
	CGDat *t=e->dat();
	if( !t || value!=t->value || linkage!=t->linkage || exps.size()!=t->exps.size() ) return false;
	for( int k=0;k<t->exps.size();++k ){
		if( !exps[k]->equals(t->exps[k]) ) return false;
	}
	return true;
}

CGExp *CGDat::visit( CGVisitor &vis ){
	bool copy=false;
	vector<CGExp*> t_exps;
	t_exps.resize( exps.size() );
	for( int k=0;k<exps.size();++k ){
		t_exps[k]=exps[k]->visit(vis);
		if( t_exps[k]!=exps[k] ) copy=true;
	}
	if( !copy ) return vis.visit(this);
	CGDat *t=new CGDat;
	t->type=type;t->value=value;t->linkage=linkage;t->exps=t_exps;
	return vis.visit( t );
}

void CGDat::push_back( CGExp *exp ){
	exps.push_back(exp);
}
